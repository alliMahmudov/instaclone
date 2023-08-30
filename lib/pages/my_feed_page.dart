import 'package:cached_network_image/cached_network_image.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instaclone/services/db_service.dart';
import 'package:share_plus/share_plus.dart';

import '../model/post_model.dart';
import '../services/utils_service.dart';

class MyFeedPage extends StatefulWidget {
  final PageController? pageController;

  const MyFeedPage({super.key, this.pageController});

  @override
  State<MyFeedPage> createState() => _MyFeedPageState();
}

class _MyFeedPageState extends State<MyFeedPage> {
  bool isLoading = false;
  List<Post> items = [];
  final ImagePicker _picker = ImagePicker();


  _apiLoadFeeds() {
    setState(() {
      isLoading = true;
    });
    DBService.loadFeeds().then((value) => {
          _resLoadFeeds(value),
        });
  }

  _resLoadFeeds(List<Post> posts) {
    setState(() {
      items = posts;
      isLoading = false;
    });
  }

  void _apiPostLike(Post post) async {
    setState(() {
      isLoading = true;
    });
    await DBService.likePost(post, true);
    setState(() {
      isLoading = false;
      post.liked = true;
    });
  }

  void _apiPostUnlike(Post post) async {
    setState(() {
      isLoading = true;
    });
    await DBService.likePost(post, false);
    setState(() {
      isLoading = false;
      post.liked = false;
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
            _apiLoadFeeds(),
          });
    }
  }

  @override
  void initState() {
    super.initState();
    _apiLoadFeeds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            "Instagram",
            style: TextStyle(
                color: Colors.black, fontFamily: "Billabong", fontSize: 30),
          ),
          actions: [
            IconButton(
              onPressed: () {
                widget.pageController!.animateToPage(2,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeIn);
              },
              icon: const Icon(Icons.camera_alt),
              color: const Color.fromRGBO(245, 96, 64, 1),
            )
          ],
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
                                  fit: BoxFit.cover)
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
            width: MediaQuery.of(context).size.width,
            imageUrl: post.imgPost,
            placeholder: (context, url) => const Center(
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
                        if (!post.liked) {
                          _apiPostLike(post);
                        } else {
                          _apiPostUnlike(post);
                        }
                      },
                      icon: post.liked
                          ? const Icon(EvaIcons.heart, color: Colors.red)
                          : const Icon(EvaIcons.heartOutline,
                              color: Colors.black)),
                  IconButton(
                    onPressed: () {
                      Share.share(post.imgPost);
                      },
                    icon: const Icon(EvaIcons.paperPlane),
                  ),
                ],
              )
            ],
          ),

          // #caption
          Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.only(left: 10, right: 10),
            child: RichText(
              softWrap: true,
              overflow: TextOverflow.visible,
              text: TextSpan(
                text: post.caption,
                style: const TextStyle(color: Colors.black),
              ),
            ),
          )
        ],
      ),
    );
  }
}
