import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:tweet_ui/tweet_ui.dart';
import 'package:http/http.dart' as http;

enum TweetType { v1, v2 }

/// Widget containing 4 Tweet types:
/// TweetView, CompactTweetView, TweetView with a quoted Tweet, CompactTweetView with a quoted Tweet
class TweetPage extends StatelessWidget {
  /// The AppBar title and prefix for the header title
  final String mediaType;

  /// The path to a Tweet JSON file
  final String tweetPath;

  /// The path to a Tweet with a embedded quote JSON file
  final String? quoteTweetPath;

  final TweetType tweetType;

  const TweetPage(
    this.mediaType,
    this.tweetPath,
    this.quoteTweetPath, {
    this.tweetType = TweetType.v1,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(mediaType),
      ),
      body: ListView(
        children: <Widget>[
          buildHeader("$mediaType EmbeddedTweetView"),
          buildEmbeddedTweetView(tweetPath),
          if (quoteTweetPath != null)
            buildHeader("$mediaType Quote EmbeddedTweetView"),
          if (quoteTweetPath != null) buildEmbeddedTweetView(quoteTweetPath!),
          buildHeader("$mediaType TweetView"),
          buildTweet(tweetPath),
          buildHeader("$mediaType CompactTweetView"),
          buildCompactTweetView(tweetPath),
          if (quoteTweetPath != null) buildHeader("$mediaType Quote TweetView"),
          if (quoteTweetPath != null) buildTweet(quoteTweetPath!),
          if (quoteTweetPath != null)
            buildHeader("$mediaType Quote CompactTweetView"),
          if (quoteTweetPath != null) buildCompactTweetView(quoteTweetPath!),
        ],
      ),
    );
  }

  /// Builds a header for a TweetView
  Widget buildHeader(String headerTitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Text(
        headerTitle,
        textAlign: TextAlign.start,
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }

  /// Builds a TweetView from a JSON file
  Widget buildEmbeddedTweetView(String jsonFile) {
    return FutureBuilder(
      future: rootBundle.loadString(jsonFile),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return Container(
            margin: EdgeInsets.all(15),
            child: _buildEmbeddedTweetFromSnapshot(snapshot),
          );
        }
        if (snapshot.hasError) {
          return Container(
            child: Text(
              snapshot.error.toString(),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }

  /// Builds a TweetView from a JSON file
  Widget buildTweet(String jsonFile) {

    return FutureBuilder(
      // future: rootBundle.loadString(jsonFile),
      future: getSingleTweetWithPhoto(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return _buildTweetFromSnapshot(snapshot);
        }
        if (snapshot.hasError) {
          return Container(
            child: Text(
              snapshot.error.toString(),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }

  /// Builds a CompactTweetView from a JSON file
  Widget buildCompactTweetView(String jsonFile) {
    return FutureBuilder(
      future: rootBundle.loadString(jsonFile),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return _buildCompactTweetFromSnapshot(snapshot);
        }
        if (snapshot.hasError) {
          return Container(
            child: Text(
              snapshot.error.toString(),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }

  Widget _buildEmbeddedTweetFromSnapshot(AsyncSnapshot snapshot) {
    switch (tweetType) {
      case TweetType.v1:
        return EmbeddedTweetView.fromTweetV1(
          TweetV1Response.fromRawJson(
            snapshot.data,
          ),
          darkMode: false,
          createdDateDisplayFormat: DateFormat("EEE, MMM d, ''yy"),
        );
      case TweetType.v2:
        return EmbeddedTweetView.fromTweetV2(
          TweetV2Response.fromRawJson(
            snapshot.data,
          ),
          darkMode: false,
          createdDateDisplayFormat: DateFormat("EEE, MMM d, ''yy"),
        );
    }
  }

  Widget _buildTweetFromSnapshot(AsyncSnapshot snapshot) {
    switch (tweetType) {
      case TweetType.v1:
        return TweetView.fromTweetV1(
          TweetV1Response.fromRawJson(
            snapshot.data,
          ),
          createdDateDisplayFormat: DateFormat("EEE, MMM d, ''yy"),
        );
      case TweetType.v2:
        return TweetView.fromTweetV2(
          TweetV2Response.fromRawJson(
            snapshot.data,
          ),
          createdDateDisplayFormat: DateFormat("EEE, MMM d, ''yy"),
        );
    }
  }

  Widget _buildCompactTweetFromSnapshot(AsyncSnapshot snapshot) {
    switch (tweetType) {
      case TweetType.v1:
        return CompactTweetView.fromTweetV1(
          TweetV1Response.fromRawJson(
            snapshot.data,
          ),
        );
      case TweetType.v2:
        return CompactTweetView.fromTweetV2(
          TweetV2Response.fromRawJson(
            snapshot.data,
          ),
        );
    }
  }

  Future<String> getSingleTweetWithPhoto() async {
    var headers = {
      'Authorization': 'Bearer AAAAAAAAAAAAAAAAAAAAAJ1iZgEAAAAACvta9ZpM8dCrnXhqfq9GVfk%2FsjU%3D02MakgCQZchjXiX0kPj2OnHyhJJnLxIuklZYcPsinP0DyHcFo1',
      'Cookie': 'guest_id=v1%3A164598761063792044; guest_id_ads=v1%3A164598761063792044; guest_id_marketing=v1%3A164598761063792044; personalization_id="v1_DmeJTA5R1njcwYbv/ifYfQ=="'
    };
    var request = http.Request('GET', Uri.parse('https://api.twitter.com/2/tweets?ids=1502308288704167938,1502306748035743746,1502306683003023371,1502306820978876417&tweet.fields=attachments,author_id,created_at,entities,geo,id,in_reply_to_user_id,lang,possibly_sensitive,referenced_tweets,source,text,withheld&expansions=attachments.media_keys&media.fields=duration_ms,height,media_key,preview_image_url,public_metrics,type,url,width'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
       String responseString =  await response.stream.bytesToString();

       //print(responseString);
       var map = jsonDecode(responseString);
       return responseString;
    }
    else {
      return await response.reasonPhrase.toString();
    }
  }

}
