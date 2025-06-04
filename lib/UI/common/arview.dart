import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:video_player/video_player.dart';

class ArView extends StatefulWidget {
  final String startLocation;
  final String endLocation;

  const ArView(
      {Key? key, required this.startLocation, required this.endLocation})
      : super(key: key);

  @override
  State<ArView> createState() => _ArViewState();
}

class _ArViewState extends State<ArView> {
  late String _videoFolderPath;
  List<String> _videoUrls = [];
  int _currentVideoIndex = 0;
  VideoPlayerController? _videoController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _videoFolderPath = '${widget.startLocation}-${widget.endLocation}';
    _fetchVideoUrls();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _fetchVideoUrls() async {
    try {
      final storageRef =
          FirebaseStorage.instance.ref('arview/$_videoFolderPath');
      final listResult = await storageRef.listAll();

      for (final item in listResult.items) {
        final downloadUrl = await item.getDownloadURL();
        setState(() {
          _videoUrls.add(downloadUrl);
        });
      }

      if (_videoUrls.isNotEmpty) {
        _initializeVideoPlayer();
      } else {
        setState(() {
          _isLoading = false;
        });
        print("No videos found for this route.");
      }
    } catch (e) {
      print("Error fetching video URLs: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _initializeVideoPlayer() {
    if (_videoUrls.isNotEmpty) {
      _videoController =
          VideoPlayerController.network(_videoUrls[_currentVideoIndex])
            ..initialize().then((_) {
              setState(() {
                _isLoading = false;
                _videoController?.setLooping(true);
                _videoController?.play();
              });
            });
    }
  }

  void _nextVideo() {
    if (_currentVideoIndex < _videoUrls.length - 1) {
      setState(() {
        _currentVideoIndex++;
        _videoController?.dispose();
        _videoController = null;
        _isLoading = true;
      });
      _initializeVideoPlayer();
    }
  }

  void _previousVideo() {
    if (_currentVideoIndex > 0) {
      setState(() {
        _currentVideoIndex--;
        _videoController?.dispose();
        _videoController = null;
        _isLoading = true;
      });
      _initializeVideoPlayer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100], // Background color from MapPage
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(top: 65, left: 16, right: 16, bottom: 16),
            child: Column(
              children: [
                Text(
                  'From: ${widget.startLocation}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'To: ${widget.endLocation}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: VideoPlayer(_videoController!),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: _videoUrls.length > 1 && _currentVideoIndex > 0
                      ? _previousVideo
                      : null,
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  disabledColor: Colors.grey,
                ),
                IconButton(
                  onPressed: _videoUrls.length > 1 &&
                          _currentVideoIndex < _videoUrls.length - 1
                      ? _nextVideo
                      : null,
                  icon: const Icon(Icons.arrow_forward, color: Colors.black),
                  disabledColor: Colors.grey,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Go back to the MapPage
              },
              child: Text('Map View'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
