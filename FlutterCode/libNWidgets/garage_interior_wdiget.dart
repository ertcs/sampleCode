mport 'dart:io';

import 'package:autoly/app_services/analytics_service.dart';
import 'package:autoly/app_services/firestoredbservice.dart';
import 'package:autoly/model/car_ad.dart';
import 'package:autoly/model/usersauth/userinfomodel.dart';
import 'package:autoly/ui/autoly_shop/garageitemmodel.dart';
import 'package:autoly/ui/myGarage/garage_interior_page/garage_interrior_main.dart';
import 'package:autoly/ui/myGarage/garage_interrior_widgets/garage_info_text_to_speech.dart';
import 'package:autoly/ui/myGarage/garage_interrior_widgets/garage_interior_widgets.dart';
import 'package:autoly/ui/myGarage/garage_interrior_widgets/photo_frame_widget.dart';
import 'package:autoly/ui/myGarage/gragemainwidgets/garage_common_util.dart';
import 'package:autoly/utilities/theme_const.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:autoly/utilities/common_const.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'adratingwidget.dart';
import 'seller_image_rating.dart';
import 'package:flutter/material.dart';

class GarageInteriorView extends StatefulWidget {
  final CarAd carAdDetail;
  final bool isViewOnly;
  final List<GarageCat> shopCatList;

  const GarageInteriorView({Key key, @required this.carAdDetail, this.isViewOnly=true, this.shopCatList}) : super(key: key);
  @override
  _GarageInteriorViewState createState() => _GarageInteriorViewState();
}

class _GarageInteriorViewState extends State<GarageInteriorView> with TickerProviderStateMixin {
  Future<List<GarageItem>> itemList;
  List<GarageItem> myGarageItemList;



  bool isSpecOpen = false;
  bool isShopOpen = false;
  bool isOpenCategory = false;
  GarageCat selectedCategory;


  setCurrentPage() async {
    await AnalyticsService().setCurrentPage(pageName: '/GarageInterior AdId:${widget.carAdDetail.adId}');
  }

  @override
  void initState() {
    super.initState();
    itemList = DBService().garageItemList(adId: widget.carAdDetail.adId);
  }



  void updateWidgetPosition({Offset offset, GarageItem item, Size size}) async {

    double rationFromBottom =
        offset.dy - MediaQuery.of(context).padding.vertical;
    double rationFromLeft =
        offset.dx - MediaQuery.of(context).padding.horizontal;


    item.rationFromBottom = rationFromBottom / size.height;
    item.rationFromLeft = rationFromLeft / size.width;
    int index = myGarageItemList.indexOf(item);
    myGarageItemList[index] = item;

    setState(() {

    });

    final CollectionReference myGarageCollection =
    FirebaseFirestore.instance.collection('test-ads').doc(widget.carAdDetail.adId).collection('garageCollection');
    await myGarageCollection.doc(item.purchaseId).update(item.toJson());
  }

  void addToGarage(GarageItem item) async {
    final CollectionReference myGarageCollection =
    FirebaseFirestore.instance.collection('test-ads').doc(widget.carAdDetail.adId).collection('garageCollection');
    DocumentReference purchaseId = myGarageCollection.doc();
    item.rationFromBottom = 0.5;
    item.rationFromLeft = 0.5;
    item.purchaseId = purchaseId.id;
    item.isAddedToGarage = true;
    myGarageItemList.add(item);

    setState(() {

    });


    await myGarageCollection.doc(purchaseId.id).set(item.toJson(),SetOptions(merge: true));
  }

  void removeFromFirebase(GarageItem item) async {
    myGarageItemList.remove(item);
    setState(() {

    });
    final CollectionReference myGarageCollection =
        FirebaseFirestore.instance.collection('test-ads').doc(widget.carAdDetail.adId).collection('garageCollection');
    await myGarageCollection.doc(item.purchaseId).delete();
  }

  Future<void> showWebPage(BuildContext context, String url) async {
    return showCupertinoModalBottomSheet(
      context: context,
      isDismissible: true,
      builder: (context) => Scaffold(
        appBar: AppBar(),
        body: WebViewPage(url: url),
      ),
    );
  }

  bool showWebItemWidget() {
    return widget.isViewOnly && widget.carAdDetail.isImported;
  }



  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double height = size.height - MediaQuery.of(context).padding.vertical;
    double width = size.width - MediaQuery.of(context).padding.horizontal;


    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: widget.isViewOnly? 30.getHeight():0),
        color: sliver,
        child: Stack(
          children: [
            
            Positioned(
              top: 0,
              right: 10,
              left: 10,
              child: Container(
                height: 0.26 * height,
                width: width,
                decoration: BoxDecoration(
                  color: ceruleanTwo,
                  borderRadius: BorderRadius.only(
                      bottomLeft: (Radius.circular((0.26 * height) * 0.2)),
                      bottomRight: (Radius.circular((0.26 * height) * 0.2))),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        height: size.height * 0.060,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(
                              4,
                              (index) => Container(
                                    width: width,
                                    height: 5,
                                    color: uglyBlue,
                                  )).toList(),
                        ),
                      ),
                    ),

                    // my garage text + count
                    Positioned(
                        bottom: 15,
                        left: 0,
                        right: 0,
                        child: AdRatingWidget(
                          adId: widget.carAdDetail.adId,
                        )),


                    // only myGarage Text
                    widget.isViewOnly
                        ? Positioned(
                            top: 28,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: FutureBuilder<UserInfoModel>(
                                future: DBService().getSellerInfo(
                                    sellerId: widget.carAdDetail.sellerId),
                                builder: (context, snapshot) {
                                  String garageTitle = 'My Garage';
                                  if(snapshot.connectionState==ConnectionState.done){
                                    if(snapshot.hasData){
                                      String sellerName = snapshot.data.userName;
                                      garageTitle = '${sellerName.split(' ')[0]}\'s Garage';
                                    }
                                  }
                                  return Container(
                                    width: 0.36 * size.width,
                                    height: 0.050 * size.height,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        color: waterBlueTwo, borderRadius: BorderRadius.circular((0.050 * size.height) / 3)),
                                    child: Text(
                                      garageTitle,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: bodyText1Style(context: context),
                                    ),
                                  );
                                }
                              ),
                            ),
                          )
                        : Container(),

                    // imported logo
                    showWebItemWidget()
                        ? Positioned(
                            top: 15,
                            right: 15,
                            child: GestureDetector(
                              onTap: () {
                                String url = widget.carAdDetail.importUrl;
                                showWebPage(context, url);
                              },
                              child: Container(
                                height: 36.getHeight(),
                                width: 50,
                                decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(36.getHeight() / 5)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 2,
                                    ),
                                    Text(
                                      '    from',
                                      style: grandstanderStyle.copyWith(color: black, fontSize: 10.getFontSize()),
                                    ),
                                    CachedNetworkImage(
                                      imageUrl: autoTraderLogo,
                                      height: 21,
                                      width: 50,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )
                        : Container(),

                    // price and title

                    Positioned(
                      left: 20,
                      right: 10,
                      bottom: 10,
                      child: Column(
                        children: [
                          //Title and text to speach
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text(
                                getAdTitle(carAd: widget.carAdDetail),
                                style: headline6Style(context: context),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              GarageInfoToSpeech(
                                msgToPlay: playAudioForAd(carAd);,
                              ),
                            ],
                          ),

                          // price location and kM
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          FontAwesomeIcons.tachometerAlt,
                                          color: white,
                                          size: 16,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 3),
                                          child: Text(
                                            '${getPrice(amount: widget.carAdDetail.odometerReading.toDouble())} KM',
                                            style: bodyText1Style(context: context),
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          height: 20,
                                          width: 20,
                                          decoration: BoxDecoration(
                                            color: carnation,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: SvgPicture.asset(
                                              'assets/images/icons/location_icon.svg',
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          'Toronto',
                                          style: bodyText1Style(context: context),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Container(
                                  color: greenishTeal,
                                  height: size.height * 0.048,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 5, right: 5),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '\$ ${getPrice(amount: widget.carAdDetail.price.toDouble())}',
                                          style: bodyText1Style(context: context),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: white,
                                            shape: BoxShape.circle,
                                          ),
                                          padding: EdgeInsets.all(2),
                                          child: Icon(
                                            Icons.arrow_downward_outlined,
                                            color: carnation,
                                            size: 14.getFontSize(),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),

                    //seller profile
                    widget.isViewOnly
                        ? Positioned(
                            top: 15,
                            left: 15,
                            child: SellerRatingNProfileImage(
                              sellerId: widget.carAdDetail.sellerId,
                            ),
                          )
                        : Container(),

                    //backButton
                    widget.isViewOnly
                        ? Positioned(
                            top: 0,
                            left: -10,
                            child: BackButton(
                              color: white,
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
            ),

            GarageCarpetWidget(
              carpetColor: steel,
            ),

            PhotoFrameWidget(
              imageList: widget.carAdDetail.exteriorImages,
            ),

            // bottom info sheet background
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: size.height * 0.1133,
                color: slateGrey,
              ),
            ),


            FutureBuilder<List<GarageItem>>(
                future: itemList,
                builder: (context, snapshot) {

                  if(snapshot.connectionState==ConnectionState.done){
                    if(snapshot.hasData){
                      myGarageItemList = snapshot.data;

                    }else{
                      print('no Data');
                      myGarageItemList = [];

                    }
                  }

                  return Positioned(
                    top: -46.getHeight(),
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      // color: Colors.white,
                      child: myGarageItemList != null
                          ? Stack(
                        children: myGarageItemList.map((e) {
                          return Positioned(
                            left: e.rationFromLeft * size.width,
                            top: e.rationFromBottom * size.height,
                            child: IgnorePointer(
                              ignoring: widget.isViewOnly,
                              child: Draggable<GarageItem>(
                                  data: e,
                                  feedback: DragChildWidget(
                                    imageUrl: e.imageUrl,
                                    heightRation: e.heightRation,
                                    widthRation: e.widthRation,
                                  ),
                                  childWhenDragging: Container(
                                    height: 100,
                                    width: 50,
                                  ),
                                  onDragEnd: (detail) {
                                    updateWidgetPosition(offset: detail.offset, item: e, size: size);
                                  },
                                  child: DragChildWidget(
                                    imageUrl: e.imageUrl,
                                    heightRation: e.heightRation,
                                    widthRation: e.widthRation,
                                  )),
                            ),
                          );
                        }).toList(),
                      )
                          : SizedBox(),
                    ),
                  );
                }
            ),

            widget.isViewOnly
                ? GarageBottomOptionSheet(
                    isSpecOpen: isSpecOpen,
                    carAd: widget.carAdDetail,
                    openSheetAction: () {
                      isSpecOpen = !isSpecOpen;
                      setState(() {});
                    },
                  )
                : isShopOpen
                    ? Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Stack(
                          children: [
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: (63 / 806) * size.height,
                                width: size.width,
                                decoration: BoxDecoration(
                                    color: Color(0xff194662),
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(((63 / 806) * size.height) * 0.3),
                                        topLeft: Radius.circular(((63 / 806) * size.height) * 0.3))),
                              ),
                            ),
                            Container(
                              height: size.height * 0.1133,
                              width: size.width,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12),
                                    child: isOpenCategory?GestureDetector(
                                      onTap: (){
                                        isOpenCategory =!isOpenCategory;
                                        setState(() {

                                        });
                                      },
                                      child: Container(
                                        height: ((63 / 806) * size.height) * 0.5,
                                        width: ((63 / 806) * size.height) * 0.5,
                                        decoration: BoxDecoration(color: mediumPink, shape: BoxShape.circle),
                                        child: Icon(
                                          Icons.arrow_back,
                                          color: white,
                                          size: 18,
                                        ),
                                      ),
                                    ):Container(),
                                  ),
                                  Expanded(
                                    child: isOpenCategory?
                                        ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                         key: Key(selectedCategory.title),
                                         itemCount: selectedCategory.itemList.length,
                                          itemBuilder: (context,index){
                                           return GestureDetector(
                                             onTap: (){
                                               addToGarage(selectedCategory.itemList[index]);
                                             },
                                             child: Container(
                                               height: (63 / 806) * size.height,
                                               padding: EdgeInsets.only(bottom: 8,top: 5,left: 4,right: 4),
                                               width: 70.getWidth(),
                                               child: Column(
                                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                 children: [
                                                   SvgPicture.string(selectedCategory.itemList[index].imageUrl,height:((63 / 806) * size.height-20.getHeight()),fit: BoxFit.contain,),
                                                   Row(
                                                     children: [
                                                       SvgPicture.asset('assets/images/coins/autoly_coin.svg',height: 20,width: 20,),
                                                       Container(
                                                         height: 20.getHeight(),
                                                         width: 30.getWidth(),
                                                         decoration: BoxDecoration(
                                                           color: Color(0xff275a7a),
                                                           borderRadius: BorderRadius.only(topRight: Radius.circular(15.getHeight()),bottomRight: Radius.circular(15.getHeight())),
                                                         ),
                                                         child: Padding(
                                                           padding: const EdgeInsets.all(2.0),
                                                           child: Text('100',style:  captionTextStyle(context: context),textAlign: TextAlign.center,),
                                                         ),
                                                       )
                                                     ],
                                                   )
                                                 ],
                                               ),
                                             ),
                                           );
                                          },

                                        )
                                        :ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: widget.shopCatList.length,
                                      itemBuilder: (context,index){
                                        GarageCat catItem = widget.shopCatList[index];
                                        return GestureDetector(
                                          onTap: (){
                                            isOpenCategory = true;
                                            selectedCategory = catItem;
                                            setState(() {

                                            });
                                          },
                                          child: Container(
                                            height: (63 / 806) * size.height,
                                            padding: EdgeInsets.only(bottom: 8,top: 5,left: 4,right: 4),
                                            width: 70.getWidth(),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                SvgPicture.asset(catItem.imagePath,height:((63 / 806) * size.height-20.getHeight()),fit: BoxFit.contain,),
                                                Text('${catItem.title}',style:  captionTextStyle(context: context),textAlign: TextAlign.center,)
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: GestureDetector(
                                      onTap: () {
                                        isShopOpen = false;
                                        setState(() {});
                                      },
                                      child: Container(
                                        height: ((63 / 806) * size.height) * 0.5,
                                        width: ((63 / 806) * size.height) * 0.5,
                                        decoration: BoxDecoration(color: mediumPink, shape: BoxShape.circle),
                                        child: Icon(
                                          Icons.close,
                                          color: white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: size.height * 0.1133,
                              width: size.width,
                              child: DragTarget<GarageItem>(
                                onWillAccept: (item) {
                                  return true;
                                },
                                onAccept: (item) {
                                  removeFromFirebase(item);
                                },
                                builder: (context, candidate, rejects) {
                                  if (candidate.length > 0) {
                                    return Container(
                                      color: Colors.red.withOpacity(0.5),
                                      child: Center(
                                          child: Text(
                                            'Remove',
                                            style:
                                            grandstanderStyle.copyWith(color: Colors.white, fontSize: 23),
                                          )),
                                    );
                                  }
                                  return Container();

                                },
                              ),
                            )


                          ],
                        ),
                      )
                    : Positioned(
                        bottom: 0,
                        right: 0,
                        left: 0,
                        child: AdStateWidget(
                          adId: widget.carAdDetail.adId,
                          openShop: () {
                            isShopOpen = true;
                            setState(() {});
                          },
                        )),


          ],
        ),
      ),
    );
  }
}