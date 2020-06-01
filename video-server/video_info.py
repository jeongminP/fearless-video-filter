class VideoInfo:
    clipNo = ''
    title = ''
    thumbnailUrl = ''
    channelEmblemUrl = ''
    channelName = ''
    duration = ''

    # constructor
    def __init__(self, clipNo, title, thumbnailUrl, channelEmblemUrl, channelName, duration):
        self.clipNo = clipNo
        self.title = title
        self.thumbnailUrl = thumbnailUrl
        self.channelEmblemUrl = channelEmblemUrl
        self.channelName = channelName
        self.duration = duration

    # getter
    def get_video_info(self):
        return {
            'clipNo': self.clipNo,
            'title': self.title,
            'thumbnailUrl': self.thumbnailUrl,
            'channelEmblemUrl': self.channelEmblemUrl,
            'channelName': self.channelName,
            'duration': self.duration
        }