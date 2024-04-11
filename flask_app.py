import time
from flask import Flask, request, jsonify
from flask import Flask, jsonify
import asyncio
from aiohttp import ClientSession
import requests
import re
import os
import json
from datetime import datetime
from flask import Flask, send_from_directory
from requests import RequestException

app = Flask(__name__)
cookies =

headers =

IMAGES_DIRECTORY = "D:\\github\\drf-chat-course\\another"
# 自行修改
# 用于存储迭代位置的全局变量
iteration_pos = 0
def download_image_web(url, id):

    print("------------")
    print(url)
    try:
        response = requests.get(url, cookies=cookies, headers=headers)
        if response.status_code == 200:
            # 解析文件后缀
            file_extension = os.path.splitext(url)[1]
            # 构造文件名
            filename = f"{id}_small{file_extension}"
            # 保存文件到本地
            with open(filename, 'wb') as f:
                f.write(response.content)
            return filename
        else:
            print(f"Failed to download image: {url}, status code: {response.status_code}")
            return None
    except Exception as e:
        print(f"Error downloading image: {e}, url: {url}")
        return None

@app.route('/download_images', methods=['POST'])
def download_images():
    data = request.json
    # print("????")
    # print(data)
    if not data or 'images' not in data:
        return jsonify({"error": "No image URLs provided"}), 400

    downloaded_files = []
    for image_info in data['images']:
        url = image_info.get('small')
        id = image_info.get('id')
        if url and id:
            filename = download_image_web(url, id)
            if filename:
                downloaded_files.append(filename)

    if downloaded_files:
        return jsonify({"message": "Images downloaded successfully", "filenames": downloaded_files})
    else:
        return jsonify({"error": "Failed to download any images"}), 500




@app.route('/images/<filename>')
def serve_image(filename):
    """提供一个通过文件名访问图片的路由."""

    return send_from_directory(IMAGES_DIRECTORY, filename)
@app.route('/images_detailNew/<filename>')
def images_detailNew(filename):
    """提供一个通过文件名访问图片的路由."""

    return send_from_directory(IMAGES_DIRECTORY, filename)

@app.route('/search_by_tag')
def search_by_tag():
    # 从请求参数中安全地获取关键词，避免直接从前端未经验证的输入构建请求
    word = request.args.get('word', default='洩矢諏訪子')
    page_start = int(request.args.get('page_start', 1))
    page_end = int(request.args.get('page_end', 5))

    artworks = []

    for page in range(page_start, page_end + 1):
        params = {
            'word': word,
            'order': 'date_d',
            'mode': 'all',
            'p': page,
            'csw': '0',
            's_mode': 's_tag_full',
            'type': 'all',
            'lang': 'zh'
        }

        try:
            response = requests.get(
                'https://www.pixiv.net/ajax/search/artworks/{}'.format(word),
                params=params,
                cookies=cookies,
                headers=headers
            )

            # 解析响应
            if response.status_code == 200:
                data = response.json()
                if not data['error']:
                    for item in data['body']['illustManga']['data']:
                        artwork_info = {
                            "id": item['id'],
                            "url": item['url'],
                            "tags": item['tags']
                        }
                        artworks.append(artwork_info)
                else:
                    # 当响应存在错误时
                    return jsonify({"error": "Pixiv returned an error in data."}), 500
            else:
                # 当响应状态码不是200时
                return jsonify({"error": "Failed to fetch data from Pixiv."}), 500
        except RequestException as e:
            # 处理请求过程中发生的异常
            return jsonify({"error": str(e)}), 500
        finally:
            # 每次请求后暂停1秒
            time.sleep(1)

    # 将结果转换为JSON并返回
    return jsonify(artworks)


@app.route('/get_detail_slow')
def get_detail_slow():
    print("????")
    page = request.args.get('page', default=1, type=int)  # 获取页码，默认为1
    size = request.args.get('size', default=10, type=int)  # 获取每页大小，默认为10
    today = datetime.now().strftime('%Y-%m-%d')
    filename = f'pixiv_details_{today}.json'
    print("????")
    try:
        with open(filename, 'r', encoding='utf-8') as file:
            # 读取整个文件内容，然后解析为JSON
            print("????")
            data =[]
            for i in file:
                data.append(i)
            print(data)
            # 根据页码和每页大小计算返回的数据切片
            print("????")
            start = (page - 1) * size
            end = start + size
            sliced_data = data[start:end]
            return jsonify(sliced_data)
    except FileNotFoundError:
        return jsonify({"error": "File not found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/get_details')
def get_details():
    global iteration_pos
    print(iteration_pos)
    try:
        num_items = int(request.args.get('num_items', 4))  # 默认获取10项
        today = datetime.now().strftime('%Y-%m-%d')
        filename = f'pixiv_details_{today}.json'

        # 确保以UTF-8编码读取文件
        with open(filename, 'r', encoding='utf-8') as f:
            data = [json.loads(line) for line in f]

        data_len = len(data)
        # print(data_len)
        start_pos = iteration_pos
        # print(num_items)
        end_pos = start_pos + num_items
        # print(start_pos)
        # 如果迭代到了数据末尾，则循环回到开头
        if end_pos > data_len:
            end_pos %= data_len
            iteration_pos = end_pos  # 更新迭代位置以反映循环

        # 获取指定范围的数据，考虑循环
        if start_pos < data_len:
            result_data = data[start_pos:end_pos] if end_pos <= data_len else data[start_pos:] + data[:end_pos - data_len]
            iteration_pos += num_items
        else:
            result_data = data[data_len - end_pos:]
            iteration_pos = 0 # 重置迭代位置
        if len(result_data) == 0:
            result_data = data[data_len - num_items:]
        return jsonify(result_data)
    except FileNotFoundError:
        return jsonify({"error": "Data file not found."}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500

async def fetch_detail(session, illust_id):
    url = f'https://www.pixiv.net/ajax/illust/{illust_id}'
    # print(url)
    async with session.get(url, cookies=cookies, headers=headers) as response:
        data = await response.json(content_type=None)
        print(data)
        body = data['body']
        result = {
            "id": body['id'],
            "tags": [tag['tag'] for tag in body['tags']['tags']],
            "urls": body['urls']
        }
        return result

@app.route('/images_detail/<id>')
def images_detail(id):

    url = 'https://www.pixiv.net/ajax/illust/'+id
    # print(url)
    response = requests.get(url, cookies=cookies, headers=headers)
    print("???")
    if response.status_code == 200:
        print("????")
        data = response.json()
        # print(data)
        body = data['body']
        result = {
            "id": body['id'],
            "tags": [tag['tag'] for tag in body['tags']['tags']],
            "urls": body['urls']
        }
        if os.path.exists(result['id'] + '_small.jpg'):
            return result
        if download_image_web(result['urls']['small'], result['id']):
            return result
        return result

        # try:
        #     response = requests.get(result["urls"]["regular"], cookies=cookies, headers=headers)
        #     if response.status_code == 200:
        #         # 解析文件后缀
        #         file_extension = result["urls"]["regular"].split('.')[-1]
        #
        #         # 构造文件名
        #         filename = f"{id}_regular.{file_extension}"
        #         result["urls"]["regular"] = filename
        #         if os.path.exists(filename):
        #             return result
        #         # 保存文件到本地
        #         with open(filename, 'wb') as f:
        #             f.write(response.content)
        #
        #     else:
        #         print(f"Failed to download image: {url}, status code: {response.status_code}")
        #         return result
        # except Exception as e:
        #     print(f"Error downloading image: {e}, url: {url}")
        #     return result

        # return result


async def fetch_details_for_ids(illust_ids):
    async with ClientSession() as session:
        details = []
        print("------")
        print(illust_ids)
        for i, illust_id in enumerate(illust_ids, start=1):
            detail = await fetch_detail(session, illust_id)
            details.append(detail)
            # 每爬取10张图片后暂停1秒
            if i % 10 == 0:
                await asyncio.sleep(1)
        return details


def fetch_ids_for_all_modes():


    modes = ['weekly', 'monthly', 'daily','rookie','original','daily_ai','male']
    all_ids = []

    for mode in modes:
        print(f"Fetching IDs for mode: {mode}")
        params = {'mode': mode}
        url = 'https://www.pixiv.net/ranking.php'
        response = requests.get(url, params=params, cookies=cookies, headers=headers)

        if response.status_code == 200:
            ids = re.findall(r'data-id="(\d+)"', response.content.decode('utf-8'))
            all_ids.append(ids[:50])
        else:
            print(f"Failed to fetch data for mode {mode}. Status code: {response.status_code}")


        time.sleep(1)  # Pause for 1 second to avoid triggering anti-scraping mechanisms

        # 去除重复的ID，同时保持顺序

    # 使用列表推导式将所有子列表合并为一个列表
    combined_ids = [id for sublist in all_ids for id in sublist]

    # 将合并后的列表转换为集合去重，然后再转换回列表
    unique_ids = list(set(combined_ids))

    print(unique_ids)
    print("over")
    return unique_ids



@app.route('/get_ids')
def get_ids():



    # 检查哪些ID已被处理
    today = datetime.now().strftime('%Y-%m-%d')
    all_json = []
    filename = f'pixiv_details_{today}.json'
    all_json = []
    if os.path.exists(filename):
        with open(filename, 'r', encoding='utf-8') as f:
            for line in f:
                data = json.loads(line)
                all_json.append(data)
                print(data)  # 添加打印语句
                if os.path.exists(data['id'] + '_small.jpg'):
                    continue
                download_image_web(data['urls']['small'], data['id'])
        return all_json
    all_ids = fetch_ids_for_all_modes()
    all_ids = list(set(all_ids))



    if os.path.exists(filename):

        with open(filename, 'r',encoding='utf-8') as f:
            processed_ids = {json.loads(line)['id'] for line in f}
            print("---------")
            for line in f:
                print(line)
                data = json.loads(line)
                print(data)
                all_json.append(data)
            print("---------")
            print(jsonify(all_json))
            return jsonify(all_json)


    else:
        processed_ids = set()
    # print(all_ids)
    # 过滤掉已经爬取的ID
    ids_to_fetch = [illust_id for illust_id in all_ids if illust_id not in processed_ids]
    # print(processed_ids)
    # 异步运行fetch_details_for_ids
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    details = loop.run_until_complete(fetch_details_for_ids(ids_to_fetch))
    print("???")

    print(details)
    # 将新获取的详情追加到文件中
    with open(filename, 'a', encoding='utf-8') as f:  # 添加了encoding参数
        for detail in details:
            json.dump(detail, f, ensure_ascii=False)
            f.write('\n')

    return jsonify(details)


@app.route('/')
def home():
    return 'Hello, HTTPS!'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=443, ssl_context=('cert.pem', 'key.pem'))



