import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class MobileYoutube extends StatelessWidget {
  const MobileYoutube({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final YoutubePlayerController _controller = YoutubePlayerController(
        initialVideoId: 'N0tNPT-3gLE',
        flags: const YoutubePlayerFlags(autoPlay: true));

    return YoutubePlayer(
      controller: _controller,
    );
  }
}
