import 'package:cached_network_image/cached_network_image.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:instaclone/services/db_service.dart';
import '../model/post_model.dart';
import '../services/utils_service.dart';

class MyLikesPage extends StatefulWidget {
  const MyLikesPage({super.key});

  @override
  State<MyLikesPage> createState() => _MyLikesPageState();
}

class _MyLikesPageState extends State<MyLikesPage> {
  bool isLoading = false;
  List<Post> items = [];

  void _apiLoadLikes() {
    setState(() {
      isLoading = true;
    });

    DBService.loadLikes().then((value) =>
    {
      _resLoadPosts(value),
    });
  }

  void _resLoadPosts(List<Post> posts) {
    setState(() {
      items = posts;
      isLoading = false;
    });
  }

  void _apiPostUnlike(Post post) {
    setState(() {
      isLoading = true;
      post.liked = false;
    });

    DBService.likePost(post, false).then((value) =>
    {
      _apiLoadLikes(),
    });
  }

  _dialogRemovePost(Post post) async {
    var result = await Utils.dialogCommon(
        context, "Insta Clone", "Do you want to delete this post?", false);
    if (result != null && result) {
      setState(() {
        isLoading = true;
      });
      DBService.removePost(post).then((value) => {
      _apiLoadLikes(),
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _apiLoadLikes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            "Likes",
            style: TextStyle(
                color: Colors.black, fontFamily: "Billabong", fontSize: 30),
          ),
        ),
        body: Stack(
          children: [
            ListView.builder(
                itemCount: items.length,
                itemBuilder: (ctx, index) {
                  return _itemOfPost(items[index]);
                }),
            isLoading
                ? const Center(
              child: CircularProgressIndicator(),
            )
                : const SizedBox.shrink(),
          ],
        ));
  }

  Widget _itemOfPost(Post post) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const Divider(),
          // #user info
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: post.img_user.isEmpty
                              ? const Image(
                            image: AssetImage("assets/images/img.png"),
                            width: 40,
                            height: 40,
                          )
                              : Image.network(
                            post.img_user,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          )),
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.fullname,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          const SizedBox(
                            height: 3,
                          ),
                          Text(
                            post.date,
                            style:
                            const TextStyle(fontWeight: FontWeight.normal),
                          )
                        ],
                      )
                    ],
                  ),
                  post.mine
                      ? IconButton(
                    icon: const Icon(Icons.more_horiz),
                    onPressed: () {
                      _dialogRemovePost(post);
                    },
                  )
                      : const SizedBox.shrink(),
                ],
              )),
          // #post image
          const SizedBox(
            height: 8,
          ),
          CachedNetworkImage(
            width: MediaQuery
                .of(context)
                .size
                .width,
            imageUrl: post.imgPost,
            placeholder: (context, url) =>
            const Center(
              child: CircularProgressIndicator(),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            fit: BoxFit.cover,
          ),

          // #like share
          Row(
            children: [
              Row(
                children: [
                  IconButton(
                      onPressed: () {
                        _apiPostUnlike(post);
                      },
                      icon: post.liked
                          ? const Icon(
                        EvaIcons.heart,
                        color: Colors.red,
                      )
                          : const Icon(
                        EvaIcons.heartOutline,
                        color: Colors.black,
                      )),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(EvaIcons.share),
                  ),
                ],
              )
            ],
          ),

          // #caption
          Container(
            width: MediaQuery
                .of(context)
                .size
                .width,
            margin: EdgeInsets.only(left: 10, right: 10),
            child: RichText(
              softWrap: true,
              overflow: TextOverflow.visible,
              text: TextSpan(
                text: post.caption,
                style: TextStyle(color: Colors.black),
              ),
            ),
          )
        ],
      ),
    );
  }
}
