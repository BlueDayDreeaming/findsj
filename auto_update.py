#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Auto Update Stata Journal Database with Citation Information
自动更新 Stata Journal 数据库，包含完整引文信息

功能：
1. 从 Stata Journal 官网爬取文章列表和 DOI
2. 通过 CrossRef API 获取详细引文信息（作者、标题、摘要、引用次数等）
3. 更新本地数据库文件

作者: GitHub Copilot
日期: 2026-02-03
"""

import requests
from bs4 import BeautifulSoup
import pandas as pd
import re
import time
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed
import logging
from datetime import datetime
import json

# 设置日志
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# 基础配置
BASE_URL = "https://www.stata-journal.com"
CROSSREF_API = "https://api.crossref.org/works"
HEADERS = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
}

def get_crossref_citation(doi, retry=3):
    """
    从 CrossRef API 获取详细引文信息
    
    Args:
        doi: DOI 标识符
        retry: 重试次数
    
    Returns:
        dict: 包含引文信息的字典
    """
    if not doi:
        return {}
    
    url = f"{CROSSREF_API}/{doi}"
    
    for attempt in range(retry):
        try:
            time.sleep(0.2)  # 在每次请求前添加延迟
            response = requests.get(url, timeout=15)
            
            # 特殊处理429错误
            if response.status_code == 429:
                wait_time = 60  # 等待60秒
                logger.warning(f"Rate limit hit for DOI {doi}. Waiting {wait_time} seconds...")
                time.sleep(wait_time)
                continue
            
            response.raise_for_status()
            data = response.json()
            
            if 'message' not in data:
                return {}
            
            message = data['message']
            
            # 提取关键信息
            citation_info = {
                'doi': message.get('DOI', doi),
                'title': message.get('title', [''])[0] if message.get('title') else '',
                'container_title': message.get('container-title', [''])[0] if message.get('container-title') else '',
                'publisher': message.get('publisher', ''),
                'volume': str(message.get('volume', '')),
                'issue': str(message.get('issue', '')),
                'page': message.get('page', ''),
                'article_type': message.get('type', ''),
                'reference_count': message.get('reference-count', 0),
                'cited_by_count': message.get('is-referenced-by-count', 0),
                'url': message.get('URL', ''),
            }
            
            # 提取出版日期
            published = message.get('published-print') or message.get('published-online') or {}
            date_parts = published.get('date-parts', [[]])
            if date_parts and date_parts[0]:
                parts = date_parts[0]
                citation_info['year'] = parts[0] if len(parts) > 0 else ''
                citation_info['month'] = parts[1] if len(parts) > 1 else ''
            else:
                citation_info['year'] = ''
                citation_info['month'] = ''
            
            # 提取作者信息
            authors = message.get('author', [])
            if authors:
                # 第一作者
                first_author = authors[0]
                citation_info['first_author_family'] = first_author.get('family', '')
                citation_info['first_author_given'] = first_author.get('given', '')
                
                # 所有作者（格式化）
                author_list = []
                for author in authors:
                    family = author.get('family', '')
                    given = author.get('given', '')
                    if family:
                        author_list.append(f"{family}, {given}" if given else family)
                
                citation_info['authors'] = '; '.join(author_list)
                citation_info['author_count'] = len(authors)
            else:
                citation_info['first_author_family'] = ''
                citation_info['first_author_given'] = ''
                citation_info['authors'] = ''
                citation_info['author_count'] = 0
            
            # 提取摘要（去除HTML标签）
            abstract = message.get('abstract', '')
            if abstract:
                # 去除 HTML/XML 标签
                clean_abstract = re.sub(r'<[^>]+>', '', abstract)
                citation_info['abstract'] = clean_abstract.strip()
            else:
                citation_info['abstract'] = ''
            
            # 提取 PDF 链接
            links = message.get('link', [])
            pdf_url = ''
            for link in links:
                if 'pdf' in link.get('content-type', '').lower():
                    pdf_url = link.get('URL', '')
                    break
            citation_info['pdf_url'] = pdf_url
            
            # ISSN
            issn_list = message.get('ISSN', [])
            citation_info['issn'] = issn_list[0] if issn_list else ''
            
            # 格式化的引用文本 (APA style)
            citation_text = format_citation_apa(citation_info)
            citation_info['citation_apa'] = citation_text
            
            logger.debug(f"Successfully fetched citation for DOI: {doi}")
            return citation_info
            
        except requests.RequestException as e:
            logger.warning(f"Attempt {attempt + 1}/{retry} failed for DOI {doi}: {e}")
            if attempt < retry - 1:
                time.sleep(2 ** attempt)  # 指数退避
        except Exception as e:
            logger.error(f"Error parsing citation for DOI {doi}: {e}")
            return {}
    
    logger.error(f"Failed to fetch citation for DOI: {doi}")
    return {}

def _given_names_to_initials(given_names):
    """Convert given names to APA-style initials, preserving hyphens."""
    initials = []
    for name_part in re.split(r'\s+', str(given_names).strip()):
        if not name_part:
            continue

        hyphenated = []
        for component in name_part.split('-'):
            match = re.search(r'[^\W\d_]', component, flags=re.UNICODE)
            if match:
                hyphenated.append(f"{match.group(0).upper()}.")

        if hyphenated:
            initials.append('-'.join(hyphenated))

    return ' '.join(initials)


def format_authors_apa(authors):
    """
    Convert the stored ``Family, Given; Family, Given`` author list to APA style.
    """
    formatted = []
    for raw_author in str(authors or '').split(';'):
        raw_author = raw_author.strip()
        if not raw_author:
            continue

        if ',' in raw_author:
            family, given = raw_author.split(',', 1)
            family = family.strip()
            initials = _given_names_to_initials(given)
            formatted.append(
                f"{family}, {initials}" if initials else family
            )
        else:
            # Preserve an organization name or an already unstructured name.
            formatted.append(raw_author)

    if not formatted:
        return ''
    if len(formatted) == 1:
        return formatted[0]
    if len(formatted) == 2:
        return f"{formatted[0]}, & {formatted[1]}"
    return ', '.join(formatted[:-1]) + f", & {formatted[-1]}"


def _clean_year(value):
    """Return a stable year string for values read from Crossref or pandas."""
    if value is None or value == '':
        return ''
    text = str(value).strip()
    if re.fullmatch(r'\d+\.0', text):
        text = text[:-2]
    return text


def _end_with_period(text):
    """Add terminal punctuation without producing duplicate periods."""
    text = str(text or '').strip()
    if not text:
        return ''
    return text if text[-1] in '.!?' else text + '.'


def format_citation_apa(info):
    """
    格式化引用文本（APA 风格）
    
    Args:
        info: 引文信息字典
    
    Returns:
        str: 格式化的引用文本
    """
    parts = []
    authors_apa = info.get('authors_apa') or format_authors_apa(
        info.get('authors', '')
    )
    year = _clean_year(info.get('year'))
    title = str(info.get('title') or '').strip()

    if authors_apa:
        author_year = authors_apa
        if year:
            author_year += f" ({year})."
        else:
            author_year += '.'
        parts.append(author_year)
        if title:
            parts.append(_end_with_period(title))
    else:
        # APA places the title in the author position when no author is known.
        if title:
            parts.append(_end_with_period(title))
        if year:
            parts.append(f"({year}).")

    journal = str(info.get('container_title') or '').strip()
    if re.match(r'^the stata journal(?:\s*:.*)?$', journal, flags=re.I):
        journal = 'The Stata Journal'

    if journal:
        journal_part = journal
        volume = _clean_year(info.get('volume'))
        issue = _clean_year(info.get('issue'))
        page = str(info.get('page') or '').strip()
        page = re.sub(r'(?<=\d)-(?=\d)', '–', page)

        if volume:
            journal_part += f", {volume}"
            if issue:
                journal_part += f"({issue})"
        if page:
            journal_part += f", {page}"

        parts.append(_end_with_period(journal_part))

    return ' '.join(parts)

def get_web_info(doi, vol, num, title_fallback=''):
    """
    从网页获取文章的完整信息（作者、标题、摘要、页码等）
    
    Args:
        doi: DOI 标识符
        vol: 卷号
        num: 期号
        title_fallback: 备用标题
    
    Returns:
        dict: 包含文章信息的字典
    """
    if not doi:
        return {}
    
    # 构造文章页面 URL（通过DOI）
    article_url = f"https://journals.sagepub.com/doi/{doi}"
    
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
    }
    
    try:
        response = requests.get(article_url, headers=headers, timeout=15)
        response.raise_for_status()
        soup = BeautifulSoup(response.text, 'html.parser')
        
        result = {}
        
        # 提取作者信息
        # 查找作者列表
        author_list = []
        author_section = soup.find('div', class_='accordion-tabbed loa-accordion')
        if not author_section:
            # 尝试其他可能的选择器
            author_section = soup.find('div', class_='author-list')
        
        if author_section:
            # 查找所有作者链接或span
            author_elements = author_section.find_all(['a', 'span'], class_=re.compile(r'author'))
            for elem in author_elements:
                author_name = elem.get_text(strip=True)
                if author_name and len(author_name) > 1:
                    author_list.append(author_name)
        
        if author_list:
            result['authors'] = '; '.join(author_list)
            # 提取第一作者
            first_author = author_list[0]
            # 尝试分离姓和名
            if ',' in first_author:
                parts = first_author.split(',', 1)
                result['first_author_family'] = parts[0].strip()
                result['first_author_given'] = parts[1].strip() if len(parts) > 1 else ''
            else:
                # 假设最后一个单词是姓
                parts = first_author.split()
                if len(parts) > 1:
                    result['first_author_family'] = parts[-1]
                    result['first_author_given'] = ' '.join(parts[:-1])
                else:
                    result['first_author_family'] = first_author
                    result['first_author_given'] = ''
            result['author_count'] = len(author_list)
        
        # 提取摘要
        abstract_section = soup.find('div', class_='abstractSection')
        if not abstract_section:
            abstract_section = soup.find('section', {'data-wrapper': 'abstract'})
        if not abstract_section:
            abstract_section = soup.find('div', class_='article-section__content', attrs={'role': 'paragraph'})
        
        if abstract_section:
            # 获取纯文本，去除HTML标签
            abstract_text = abstract_section.get_text(separator=' ', strip=True)
            # 清理多余空格
            abstract_text = re.sub(r'\s+', ' ', abstract_text)
            result['abstract'] = abstract_text
        else:
            result['abstract'] = ''
        
        # 提取标题
        title_elem = soup.find('h1', class_='citation__title')
        if not title_elem:
            title_elem = soup.find('h1', class_='article-title')
        if title_elem:
            result['title'] = title_elem.get_text(strip=True)
        else:
            result['title'] = title_fallback
        
        # 提取页码
        page_elem = soup.find('span', class_='article-page-range')
        if not page_elem:
            page_elem = soup.find('span', class_='page-range')
        if page_elem:
            result['page'] = page_elem.get_text(strip=True)
        else:
            result['page'] = ''
        
        # 提取PDF链接
        pdf_link = soup.find('a', class_='show-pdf')
        if not pdf_link:
            pdf_link = soup.find('a', href=re.compile(r'/doi/pdf/'))
        if pdf_link:
            pdf_href = pdf_link.get('href', '')
            if pdf_href.startswith('/'):
                result['pdf_url'] = f"https://journals.sagepub.com{pdf_href}"
            else:
                result['pdf_url'] = pdf_href
        else:
            result['pdf_url'] = ''
        
        # URL
        result['url'] = article_url
        
        if result:
            logger.debug(f"Web info for DOI {doi}: {list(result.keys())}")
        
        return result
        
    except Exception as e:
        logger.debug(f"Failed to get web info for DOI {doi}: {e}")
        return {}

def get_article_doi_from_page(artid):
    """
    从文章页面获取 DOI
    
    Args:
        artid: 文章ID（如 st0001, dm122）
    
    Returns:
        str: DOI 或空字符串
    """
    url = f"{BASE_URL}/article.html?article={artid}"
    
    try:
        response = requests.get(url, headers=HEADERS, timeout=10)
        response.raise_for_status()
        soup = BeautifulSoup(response.text, 'html.parser')
        
        # 查找 Sage 期刊链接
        sage_link = soup.find('a', href=re.compile(r'journals\.sagepub\.com/doi/'))
        if sage_link:
            href = sage_link.get('href', '')
            doi_match = re.search(r'doi/(pdf/)?(10\.\d+/[^?&#]+)', href)
            if doi_match:
                return doi_match.group(2).lower()
        
        # 查找其他可能的 DOI 链接
        doi_link = soup.find('a', href=re.compile(r'doi\.org/'))
        if doi_link:
            href = doi_link.get('href', '')
            doi_match = re.search(r'10\.\d+/[^?&#\s]+', href)
            if doi_match:
                return doi_match.group(0).lower()
        
        return ''
    except Exception as e:
        logger.debug(f"Failed to get DOI for {artid}: {e}")
        return ''

def get_all_stata_journal_articles():
    """
    从 Stata Journal 搜索页面获取所有文章的 artid 和基础信息
    
    Returns:
        list: 文章信息列表（包含 artid, title, volume, number, year）
    """
    logger.info("Fetching all articles from search page...")
    
    search_url = f"{BASE_URL}/sjsearch.html?choice=keyword&q="
    
    try:
        response = requests.get(search_url, headers=HEADERS, timeout=30)
        response.raise_for_status()
        soup = BeautifulSoup(response.text, 'html.parser')
        
        # 查找所有 article.html?article= 链接
        article_links = soup.find_all('a', href=re.compile(r'article\.html\?article='))
        
        all_articles = []
        seen_artids = set()
        skipped_count = 0
        
        for link in article_links:
            href = link.get('href', '')
            match = re.search(r'article=([^"&]+)', href)
            if match:
                artid = match.group(1).strip()
                
                # 跳过 updates, announcements, emptytag 等非正式文章
                artid_lower = artid.lower()
                if artid_lower.startswith(('up', 'an', 'emptytag')):
                    skipped_count += 1
                    continue
                
                # 去重
                if artid in seen_artids:
                    continue
                seen_artids.add(artid)
                
                # 获取标题
                title = link.get_text(strip=True)
                
                # 跳过 Software updates
                if 'software update' in title.lower():
                    skipped_count += 1
                    continue
                
                # 从 artid 推断卷期年份（格式如 st0001, dm122）
                # artid格式: {type}{number}, 例如 st1234
                artid_match = re.match(r'([a-z]+)(\d+)', artid)
                if artid_match:
                    article_type = artid_match.group(1)
                    article_num = int(artid_match.group(2))
                    
                    # 粗略估算：假设st文章每年60篇左右
                    # 实际会在CrossRef API中获取准确的卷期信息
                    vol = 0
                    num = 0
                    year = 0
                    
                    all_articles.append({
                        'artid': artid,
                        'title_web': title,
                        'volume': vol,  # 待补充
                        'number': num,  # 待补充
                        'year': year    # 待补充
                    })
        
        logger.info(f"Found {len(all_articles)} articles (skipped {skipped_count} non-article entries)")
        return all_articles
        
    except Exception as e:
        logger.error(f"Error fetching from search page: {e}")
        return []

def update_database():
    """
    更新数据库主函数
    """
    logger.info("=" * 60)
    logger.info("Starting Stata Journal Database Update")
    logger.info("=" * 60)
    
    # 第一步：获取所有文章列表
    logger.info("\nStep 1: Fetching article list from Stata Journal website...")
    articles = get_all_stata_journal_articles()
    
    if not articles:
        logger.error("No articles found! Exiting.")
        return
    
    # 第二步：获取引文信息
    logger.info(f"\nStep 2: Fetching citation information from CrossRef API...")
    logger.info(f"Total articles to process: {len(articles)}")
    
    detailed_articles = []
    
    def process_article(art, index):
        """处理单篇文章"""
        artid = art.get('artid', '')
        vol = art.get('volume', '')
        num = art.get('number', '')
        year = art.get('year', '')
        
        # 先获取DOI
        doi = get_article_doi_from_page(artid)
        
        if not doi:
            # 没有 DOI 的文章，只保留基本信息
            result = {
                'art_id': artid,
                'title': art.get('title_web', ''),
                'volume': vol,
                'number': num,
                'year': year,
                'doi': '',
                'authors': '',
                'first_author_family': '',
                'first_author_given': '',
                'author_count': 0,
                'abstract': '',
                'page': '',
                'reference_count': 0,
                'cited_by_count': 0,
                'citation_apa': '',
                'url': f'{BASE_URL}/article.html?article={artid}',
                'pdf_url': '',
            }
        else:
            # 从 CrossRef 获取详细信息
            citation = get_crossref_citation(doi)
            
            if citation:
                result = {
                    'art_id': artid,
                    'title': citation.get('title', art.get('title_web', '')),
                    'volume': citation.get('volume', vol),
                    'number': citation.get('issue', num),
                    'year': citation.get('year', year),
                    'doi': doi,
                    'authors': citation.get('authors', ''),
                    'first_author_family': citation.get('first_author_family', ''),
                    'first_author_given': citation.get('first_author_given', ''),
                    'author_count': citation.get('author_count', 0),
                    'abstract': citation.get('abstract', ''),
                    'page': citation.get('page', ''),
                    'reference_count': citation.get('reference_count', 0),
                    'cited_by_count': citation.get('cited_by_count', 0),
                    'citation_apa': citation.get('citation_apa', ''),
                    'url': citation.get('url', ''),
                    'pdf_url': citation.get('pdf_url', ''),
                }
            else:
                # API 请求失败，使用基本信息
                result = {
                    'art_id': artid,
                    'title': art.get('title_web', ''),
                    'volume': vol,
                    'number': num,
                    'year': year,
                    'doi': doi,
                    'authors': '',
                    'first_author_family': '',
                    'first_author_given': '',
                    'author_count': 0,
                    'abstract': '',
                    'page': '',
                    'reference_count': 0,
                    'cited_by_count': 0,
                    'citation_apa': '',
                    'url': f'https://doi.org/{doi}',
                    'pdf_url': '',
                }
        
        if (index + 1) % 50 == 0:
            logger.info(f"Progress: {index + 1}/{len(articles)} articles processed")
        
        return result
    
    # 使用线程池并发处理（降低并发数以避免速率限制）
    with ThreadPoolExecutor(max_workers=3) as executor:
        futures = {
            executor.submit(process_article, art, i): i 
            for i, art in enumerate(articles)
        }
        
        for future in as_completed(futures):
            try:
                result = future.result()
                detailed_articles.append(result)
            except Exception as e:
                idx = futures[future]
                logger.error(f"Error processing article {idx}: {e}")
    
    # 第三步：保存数据库
    logger.info("\nStep 3: Saving to database files...")
    
    # 转换为 DataFrame
    df = pd.DataFrame(detailed_articles)
    
    # 数据清洗和排序
    for col in ['year', 'volume', 'number', 'author_count', 'reference_count', 'cited_by_count']:
        df[col] = pd.to_numeric(df[col], errors='coerce').fillna(0).astype(int)
    
    # 填充空字符串
    for col in df.columns:
        if df[col].dtype == 'object':
            df[col] = df[col].fillna('')
    
    # 按年份、卷号、期号排序（如果有的话，否则按art_id排序）
    df = df.sort_values(['year', 'volume', 'number'], ascending=[True, True, True])
    df = df.reset_index(drop=True)
    
    # 调整列顺序，将art_id放在前面
    cols = ['art_id'] + [col for col in df.columns if col != 'art_id']
    df = df[cols]
    
    # 保存主数据库文件
    output_path = Path(__file__).parent / "findsj.dta"
    df.to_stata(str(output_path), write_index=False, version=118)
    logger.info(f"✅ Main database saved: {output_path}")
    
    # 保存版本信息文件
    version_df = pd.DataFrame([{
        'update_date': datetime.now().strftime('%Y-%m-%d'),
        'update_time': datetime.now().strftime('%H:%M:%S'),
        'total_articles': len(df),
        'articles_with_doi': (df['doi'] != '').sum(),
        'articles_with_citation': (df['citation_apa'] != '').sum(),
        'year_min': int(df['year'].min()),
        'year_max': int(df['year'].max()),
    }])
    version_path = Path(__file__).parent / "findsj_version.dta"
    version_df.to_stata(str(version_path), write_index=False, version=118)
    logger.info(f"✅ Version info saved: {version_path}")
    
    # 统计信息
    logger.info("\n" + "=" * 60)
    logger.info("Database Update Summary")
    logger.info("=" * 60)
    logger.info(f"Total articles: {len(df)}")
    logger.info(f"Year range: {int(df['year'].min())} - {int(df['year'].max())}")
    logger.info(f"Articles with DOI: {(df['doi'] != '').sum()}")
    logger.info(f"Articles with authors: {(df['authors'] != '').sum()}")
    logger.info(f"Articles with abstract: {(df['abstract'] != '').sum()}")
    logger.info(f"Average citations: {df['cited_by_count'].mean():.1f}")
    logger.info(f"Total citations: {df['cited_by_count'].sum()}")
    logger.info("=" * 60)
    
    # 保存详细日志
    log_path = Path(__file__).parent / "update_log.json"
    log_data = {
        'update_datetime': datetime.now().isoformat(),
        'total_articles': len(df),
        'articles_with_doi': int((df['doi'] != '').sum()),
        'articles_with_citation': int((df['citation_apa'] != '').sum()),
        'year_range': [int(df['year'].min()), int(df['year'].max())],
        'top_cited': df.nlargest(10, 'cited_by_count')[['title', 'cited_by_count', 'year']].to_dict('records')
    }
    with open(log_path, 'w', encoding='utf-8') as f:
        json.dump(log_data, f, indent=2, ensure_ascii=False)
    logger.info(f"📋 Update log saved: {log_path}")
    
    logger.info("\n✅ Database update completed successfully!")

def main():
    """主入口函数"""
    try:
        update_database()
    except Exception as e:
        logger.error(f"Fatal error: {e}", exc_info=True)
        raise

if __name__ == "__main__":
    main()
