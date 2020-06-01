from video_info import VideoInfo
from filter_info import FilterInfo
from flask import Flask, request, jsonify

# instead of database
video_list = []
video_number = 0
filter_dict = {}
filter_number = 0

# server object
app = Flask(__name__)

# input : video id
# output : video list index
def get_video_index(clipNo):
    for index, video in enumerate(video_list):
        video_data = video.get_video_info()

        # check if clipNo matches
        if clipNo == video_data['clipNo']:
            return index

    return None

def get_filter_index(filterSrl, filter_list):
    for index, filter in enumerate(filter_list):
        filter_data = filter.get_filter_info()

        # check if filterSrl matches
        if filterSrl == filter_data['filterSrl']:
            return index

    return None

# you could fill the body when calling this function
def create_successful_response():
    response = {}
    header = {}

    header['code'] = 0
    header['message'] = 'success'

    response['header'] = header
    response['body'] = {}

    return response

def create_failed_response():
    response = {}
    header = {}

    header['code'] = -1000
    header['message'] = 'failure'

    response['header'] = header
    response['body'] = {}

    return response

# video_info CRUD
@app.route('/api/v1/clip/list', methods = ['POST'])
def add_video():
    global video_number

    req_data = request.get_json()

    if 'title' not in req_data.keys() or 'thumbnailUrl' not in req_data.keys() or 'channelEmblemUrl' not in req_data.keys()\
            or 'channelName' not in req_data.keys() or 'duration' not in req_data.keys():
        return jsonify(create_failed_response())

    title = req_data['title']
    thumbnailUrl = req_data['thumbnailUrl']
    channelEmblemUrl = req_data['channelEmblemUrl']
    channelName = req_data['channelName']
    duration = req_data['duration']
    clipNo = video_number + 1
    video_number += 1

    video = VideoInfo(clipNo, title, thumbnailUrl, channelEmblemUrl, channelName, duration)
    video_list.append(video)

    response = create_successful_response()
    return jsonify(response)

@app.route('/api/v1/clip/list', methods = ['GET'])
def show_video():
    body = {}

    if 'page' in request.args:
        page = int(request.args['page'])
    else:
        page = 1

    if 'size' in request.args:
        size = int(request.args['size'])
    else:
        size = 10

    start = (page - 1) * size
    end = page * size

    if end >= len(video_list):
        end = len(video_list)
        body['hasNext'] = False
    else:
        body['hasNext'] = True

    paging_list = video_list[start:end]

    video_info_list = []
    for video in paging_list:
        data = video.get_video_info()
        video_info_list.append(data)

    body['clips'] = video_info_list

    response = create_successful_response()
    response['body'] = body

    return jsonify(response)

@app.route('/api/v1/clip/list', methods = ['PUT'])
def edit_video():
    req_data = request.get_json()

    if 'clipNo' not in req_data.keys() or 'title' not in req_data.keys() or 'thumbnailUrl' not in req_data.keys()\
            or 'channelEmblemUrl' not in req_data.keys() or 'channelName' not in req_data.keys() \
            or 'duration' not in req_data.keys():
        return jsonify(create_failed_response())

    try:
        # get video index
        video_index = get_video_index(req_data['clipNo'])

        # if id does not exist
        if video_index == None:
            return jsonify(create_failed_response())

        # get video data
        original_video = video_list[video_index]
        original_video_data = original_video.get_video_info()

        # create new video
        clipNo = original_video_data['clipNo']
        title = req_data['title']
        thumbnailUrl = req_data['thumbnailUrl']
        channelEmblemUrl = req_data['channelEmblemUrl']
        channelName = req_data['channelName']
        duration = req_data['duration']
        new_video = VideoInfo(clipNo, title, thumbnailUrl, channelEmblemUrl, channelName, duration)

        # replace video
        video_list[video_index] = new_video

        return jsonify(create_successful_response())

    except:
        return jsonify(create_failed_response())

@app.route('/api/v1/clip/list', methods=['Delete'])
def delete_video():
    req_data = request.get_json()

    if 'clipNo' not in req_data.keys():
        return jsonify(create_failed_response())

    # get index in video_list
    video_index = get_video_index(req_data['clipNo'])

    # if id does not exist
    if video_index == None:
        return jsonify(create_failed_response())

    # delete video
    del video_list[video_index]

    return jsonify(create_successful_response())

# filter_info CRUD
@app.route('/api/v1/clip/filter/list', methods = ['POST'])
def add_filter():
    global filter_number
    req_data = request.get_json()

    if 'clipNo' not in req_data.keys() or 'startPosition' not in req_data.keys() or 'endPosition' not in req_data.keys():
        return jsonify(create_failed_response())

    clipNo = req_data['clipNo']
    startPosition = req_data['startPosition']
    endPosition = req_data['endPosition']
    filterSrl = filter_number + 1
    filter_number += 1

    filter = FilterInfo(filterSrl, startPosition, endPosition)
    if clipNo not in filter_dict:
        filter_dict[clipNo] = []
    filter_dict[clipNo].append(filter)

    response = create_successful_response()
    return jsonify(response)


@app.route('/api/v1/clip/filter/list', methods = ['GET'])
def show_filter():
    body = {}

    if 'clipNo' not in request.args:
        response = create_failed_response()
        response['header']['message'] = 'please include clipNo query param'
        return jsonify(response)

    clipNo = int(request.args['clipNo'])

    body['clipNo'] = clipNo

    if clipNo not in filter_dict:
        filter_dict[clipNo] = []
    filter_list = filter_dict[clipNo]

    filter_info_list = []
    for video in filter_list:
        data = video.get_filter_info()
        filter_info_list.append(data)

    body['filters'] = filter_info_list

    response = create_successful_response()
    response['body'] = body

    return jsonify(response)

@app.route('/api/v1/clip/filter/list', methods = ['PUT'])
def edit_filter():
    req_data = request.get_json()

    if 'clipNo' not in req_data.keys() or 'filterSrl' not in req_data.keys() or 'startPosition' not in req_data.keys() \
            or 'endPosition' not in req_data.keys():
        return jsonify(create_failed_response())

    try:
        filter_list = filter_dict[req_data['clipNo']]
        # get filter index
        filter_index = get_filter_index(req_data['filterSrl'], filter_list)

        # if id does not exist
        if filter_index == None:
            return jsonify(create_failed_response())

        # get filter data
        original_filter = filter_list[filter_index]
        original_filter_data = original_filter.get_filter_info()

        # create new filter
        filterSrl = original_filter_data['filterSrl']
        startPosition = req_data['startPosition']
        endPosition = req_data['endPosition']
        new_filter = FilterInfo(filterSrl, startPosition, endPosition)

        # replace filter
        filter_list[filter_index] = new_filter

        return jsonify(create_successful_response())

    except:
        return jsonify(create_failed_response())

@app.route('/api/v1/clip/filter/list', methods=['Delete'])
def delete_filter():
    req_data = request.get_json()

    if 'clipNo' not in req_data.keys() or 'filterSrl' not in req_data.keys():
        return jsonify(create_failed_response())

    clipNo = req_data['clipNo']
    if clipNo not in filter_dict:
        filter_dict[clipNo] = []

    filter_list = filter_dict[clipNo]

    # get index in filter_list
    filter_index = get_filter_index(req_data['filterSrl'], filter_list)

    # if id does not exist
    if filter_index == None:
        print("index dose not exist")
        return jsonify(create_failed_response())

    # delete video
    del filter_list[filter_index]

    return jsonify(create_successful_response())


app.run(host='0.0.0.0', port=80, debug=True)
