import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class WebYoutube extends StatelessWidget {
  const WebYoutube({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final YoutubePlayerController _controller = YoutubePlayerController(
      initialVideoId: 'N0tNPT-3gLE',
      params: const YoutubePlayerParams(
        mute: true,
        playlist: [
          'N0tNPT-3gLE',
        ],
        loop: true,
      ),
    );
    return YoutubePlayerControllerProvider(
      controller: _controller,
      child: const YoutubePlayerIFrame(),
    );
  }
}
