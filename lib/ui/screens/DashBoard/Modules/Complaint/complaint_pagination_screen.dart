import 'dart:io';

import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_share_me/flutter_share_me.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:soleoserp/blocs/other/bloc_modules/complaint/complaint_bloc.dart';
import 'package:soleoserp/models/api_requests/complaint/complaint_delete_request.dart';
import 'package:soleoserp/models/api_requests/complaint/complaint_list_request.dart';
import 'package:soleoserp/models/api_requests/complaint/complaint_search_by_Id_request.dart';
import 'package:soleoserp/models/api_requests/complaint/fetch_image_list.dart';
import 'package:soleoserp/models/api_responses/company_details_response.dart';
import 'package:soleoserp/models/api_responses/complaint/complaint_list_response.dart';
import 'package:soleoserp/models/api_responses/complaint/fetch_complaint_image_list_response.dart';
import 'package:soleoserp/models/api_responses/complaint_search_response.dart';
import 'package:soleoserp/models/api_responses/login_user_details_api_response.dart';
import 'package:soleoserp/ui/res/color_resources.dart';
import 'package:soleoserp/ui/res/dimen_resources.dart';
import 'package:soleoserp/ui/res/image_resources.dart';
import 'package:soleoserp/ui/screens/DashBoard/Modules/Complaint/Followup_History/complaint_followup_history.dart';
import 'package:soleoserp/ui/screens/DashBoard/Modules/Complaint/Followup_dialog/complaint_to_followup.dart';
import 'package:soleoserp/ui/screens/DashBoard/Modules/Complaint/complaint_add_edit_screen.dart';
import 'package:soleoserp/ui/screens/DashBoard/Modules/Complaint/complaint_search_screen.dart';
import 'package:soleoserp/ui/screens/DashBoard/home_screen.dart';
import 'package:soleoserp/ui/screens/base/base_screen.dart';
import 'package:soleoserp/ui/widgets/common_widgets.dart';
import 'package:soleoserp/utils/date_time_extensions.dart';
import 'package:soleoserp/utils/general_utils.dart';
import 'package:soleoserp/utils/shared_pref_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class ComplaintPaginationListScreen extends BaseStatefulWidget {
  static const routeName = '/ComplaintPaginationListScreen';

  @override
  _ComplaintPaginationListScreenState createState() =>
      _ComplaintPaginationListScreenState();
}

enum Share {
  facebook,
  twitter,
  whatsapp,
  whatsapp_personal,
  whatsapp_business,
  share_system,
  share_instagram,
  share_telegram
}

/*class JosKeys {
  static final cardA = GlobalKey<ExpansionTileCardState>();
  static final refreshKey  = GlobalKey<RefreshIndicatorState>();
}*/
class _ComplaintPaginationListScreenState
    extends BaseState<ComplaintPaginationListScreen>
    with BasicScreen, WidgetsBindingObserver, SingleTickerProviderStateMixin {
  ComplaintScreenBloc _complaintScreenBloc;
  CompanyDetailsResponse _offlineCompanyData;
  LoginUserDetialsResponse _offlineLoggedInData;
  int CompanyID = 0;
  String LoginUserID = "";
  int _pageNo = 0;
  ComplaintListResponse _inquiryListResponse;
  ComplaintSearchDetails _searchDetails;
  double sizeboxsize = 12;
  double _fontSize_Label = 9;
  double _fontSize_Title = 11;
  int label_color = 0xff4F4F4F; //0x66666666;
  int title_color = 0xff362d8b;
  bool expanded = true;
  bool isDeleteVisible = true;
  final TextEditingController edt_CustomerName = TextEditingController();

  List<FetchComplaintImageListResponseDetails> arrrImageVideoList = [];
  List<FetchComplaintImageListResponseDetails> arrrImageList = [];
  List<File> multiple_selectedImageFile = [];

  List<File> MultipleVideoList = [];

  String ImageURLFromListing = "";
  @override
  void initState() {
    super.initState();
    _offlineLoggedInData = SharedPrefHelper.instance.getLoginUserData();
    _offlineCompanyData = SharedPrefHelper.instance.getCompanyData();
    CompanyID = _offlineCompanyData.details[0].pkId;
    LoginUserID = _offlineLoggedInData.details[0].userID;
    _complaintScreenBloc = ComplaintScreenBloc(baseBloc);

    edt_CustomerName.text = "";
  }

  ///listener to multiple states of bloc to handles api responses
  ///use only BlocListener if only need to listen to events
/*
  @override
  Widget build(BuildContext context) {
    return BlocListener<CustomerPaginationListScreenBloc, CustomerPaginationListScreenStates>(
      bloc: _authenticationBloc,
      listener: (BuildContext context, CustomerPaginationListScreenStates state) {
        if (state is CustomerPaginationListScreenResponseState) {
          _onCustomerPaginationListScreenCallSuccess(state.response);
        }
      },
      child: super.build(context),
    );
  }
*/

  ///listener and builder to multiple states of bloc to handles api responses
  ///use BlocProvider if need to listen and build
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => _complaintScreenBloc
        ..add(ComplaintListCallEvent(
            1,
            ComplaintListRequest(
                CompanyId: CompanyID.toString(),
                LoginUserID: LoginUserID,
                SearchKey: edt_CustomerName.text))),
      child: BlocConsumer<ComplaintScreenBloc, ComplaintScreenStates>(
        builder: (BuildContext context, ComplaintScreenStates state) {
          //handle states
          if (state is ComplaintListResponseState) {
            _onGetListCallSuccess(state);
          }
          if (state is ComplaintSearchByIDResponseState) {
            _onSearchByIDCallSuccess(state);
          }
          return super.build(context);
        },
        buildWhen: (oldState, currentState) {
          //return true for state for which builder method should be called
          if (currentState is ComplaintListResponseState ||
              currentState is ComplaintSearchByIDResponseState) {
            return true;
          }
          return false;
        },
        listener: (BuildContext context, ComplaintScreenStates state) {
          //handle states
          if (state is ComplaintDeleteResponseState) {
            _onDeleteCallSuccess(state);
          }
          if (state is FetchComplaintImageListResponseState) {
            _OnImageListSucess(state);
          }
          return super.build(context);
        },
        listenWhen: (oldState, currentState) {
          //return true for state for which listener method should be called
          if (currentState is ComplaintDeleteResponseState ||
              currentState is FetchComplaintImageListResponseState) {
            return true;
          }
          return false;
        },
      ),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: NewGradientAppBar(
          title: Text('Complaint List'),
          gradient:
              LinearGradient(colors: [Colors.blue, Colors.purple, Colors.red]),
          actions: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.water_damage_sharp,
                  color: colorWhite,
                ),
                onPressed: () {
                  //_onTapOfLogOut();
                  navigateTo(context, HomeScreen.routeName,
                      clearAllStack: true);
                })
          ],
        ),
        body: Container(
          child: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    _complaintScreenBloc.add(ComplaintListCallEvent(
                        1,
                        ComplaintListRequest(
                            CompanyId: CompanyID.toString(),
                            LoginUserID: LoginUserID,
                            SearchKey: edt_CustomerName.text)));
                  },
                  child: Container(
                    padding: EdgeInsets.only(
                      left: DEFAULT_SCREEN_LEFT_RIGHT_MARGIN2,
                      right: DEFAULT_SCREEN_LEFT_RIGHT_MARGIN2,
                      top: 10,
                    ),
                    child: Column(
                      children: [
                        _buildSearchView(),
                        Expanded(child: _buildInquiryList())
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // Add your onPressed code here!
            navigateTo(context, ComplaintAddEditScreen.routeName);
          },
          child: const Icon(Icons.add),
          backgroundColor: colorPrimary,
        ),
        drawer: build_Drawer(
            context: context, UserName: "KISHAN", RolCode: "Admin"),
      ),
    );
  }

  Future<bool> _onBackPressed() {
    navigateTo(context, HomeScreen.routeName, clearAllStack: true);
  }

  void _onGetListCallSuccess(ComplaintListResponseState state) {
    /*for(var i=0;i<responseState.complaintListResponse.details.length;i++){

    }*/
    if (_pageNo != state.newPage || state.newPage == 1) {
      //checking if new data is arrived
      if (state.newPage == 1) {
        //resetting search
        // _searchDetails = null;
        _inquiryListResponse = state.complaintListResponse;
      } else {
        _inquiryListResponse.details
            .addAll(state.complaintListResponse.details);
      }
      _pageNo = state.newPage;
    }
  }

  Widget _buildSearchView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(left: 10, right: 20),
          child: Text("Search Customer",
              style: TextStyle(
                  fontSize: 12,
                  color: colorPrimary,
                  fontWeight: FontWeight
                      .bold) // baseTheme.textTheme.headline2.copyWith(color: colorBlack),

              ),
        ),
        SizedBox(
          height: 5,
        ),
        Card(
          elevation: 5,
          color: Color(0xffE0E0E0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Container(
            height: 60,
            padding: EdgeInsets.only(left: 20, right: 20),
            width: double.maxFinite,
            child: Row(
              children: [
                Expanded(
                  child: /*Text(
                    _searchDetails == null
                        ? "Tap to search customer"
                        : _searchDetails.label,
                    style: baseTheme.textTheme.headline3.copyWith(
                        color: _searchDetails == null
                            ? colorGrayDark
                            : colorBlack),
                  )*/
                      TextField(
                    controller: edt_CustomerName,
                    enabled: true,
                    onChanged: (value) => {
                      // print("StatusValue " + value.toString() )
                      if (value.length > 2)
                        {
                          /* dffgg
                      dffdj
                      dk
*/
                          _complaintScreenBloc.add(ComplaintListCallEvent(
                              1,
                              ComplaintListRequest(
                                  CompanyId: CompanyID.toString(),
                                  LoginUserID: LoginUserID,
                                  SearchKey: value)))
                        }
                    },
                    style: TextStyle(
                        color: Colors.black, // <-- Change this
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                    decoration: new InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.only(
                            left: 15, bottom: 11, top: 11, right: 15),
                        hintText: "Search Customer"),
                  ),
                ),
                Icon(
                  Icons.search,
                  color: colorGrayDark,
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  ///navigates to search list screen
  Future<void> _onTapOfSearchView() async {
    navigateTo(context, SearchComplaintScreen.routeName).then((value) {
      if (value != null) {
        _searchDetails = value;
        _complaintScreenBloc.add(ComplaintSearchByIDCallEvent(
            _searchDetails.pkID,
            ComplaintSearchByIDRequest(
                CompanyId: CompanyID.toString(), LoginUserID: LoginUserID)));
      }
    });
  }

  Widget _buildInquiryList() {
    if (_inquiryListResponse == null) {
      return Container();
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (shouldPaginate(
              scrollInfo,
            ) &&
            _searchDetails == null) {
          _onInquiryListPagination();
          return true;
        } else {
          return false;
        }
      },
      child: ListView.builder(
        key: Key('selected'),
        itemBuilder: (context, index) {
          return _buildInquiryListItem(index);
        },
        shrinkWrap: true,
        itemCount: _inquiryListResponse.details.length,
      ),
    );
  }

  ///builds row item view of inquiry list
  Widget _buildInquiryListItem(int index) {
    return ExpantionCustomer(context, index);
  }

  void _onInquiryListPagination() {
    _complaintScreenBloc.add(ComplaintListCallEvent(
        _pageNo + 1,
        ComplaintListRequest(
            CompanyId: CompanyID.toString(),
            LoginUserID: LoginUserID,
            SearchKey: edt_CustomerName.text)));
  }

  ExpantionCustomer(BuildContext context, int index) {
    ComplaintDetails model = _inquiryListResponse.details[index];

    return Container(
        padding: EdgeInsets.all(15),
        child: ExpansionTileCard(
          // key:Key(index.toString()),
          initialElevation: 5.0,
          elevation: 5.0,
          elevationCurve: Curves.easeInOut,
          shadowColor: Color(0xFF504F4F),
          baseColor: Color(0xFFFCFCFC),
          expandedColor: Color(0xFFC1E0FA),
          leading: CircleAvatar(
              backgroundColor: Color(0xFF504F4F),
              child: Image.network(
                "http://demo.sharvayainfotech.in/images/profile.png",
                height: 35,
                fit: BoxFit.fill,
                width: 35,
              )),
          title: Text(
            model.customerName,
            style: TextStyle(color: Colors.black),
          ),
          subtitle: GestureDetector(
            child: Text(
              model.complaintNo,
              style: TextStyle(
                color: Color(0xFF504F4F),
                fontSize: _fontSize_Title,
              ),
            ),
          ),
          children: <Widget>[
            Divider(
              thickness: 1.0,
              height: 1.0,
            ),
            SizedBox(
              height: sizeboxsize,
            ),
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () async {
                        //await _makePhoneCall(model.contactNo1);
                        await _makePhoneCall(model.custmoreMobileNo);
                      },
                      child: Container(
                        /* decoration: BoxDecoration(
                                                              shape: BoxShape.rectangle,
                                                              color: colorPrimary,
                                                              borderRadius: BorderRadius.all(Radius.circular(30)),

                                                            ),*/
                        child: /*Icon(

                                                              Icons.call,
                                                              color: colorWhite,
                                                              size: 24,
                                                            )*/
                            Image.asset(
                          PHONE_CALL_IMAGE,
                          width: 30,
                          height: 30,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    GestureDetector(
                      onTap: () async {
                        //await _makePhoneCall(model.contactNo1);
                        //await _makeSms(model.contactNo1);
                        showCommonDialogWithTwoOptions(
                            context,
                            "Do you have Two Accounts of WhatsApp ?" +
                                "\n" +
                                "Select one From below Option !",
                            positiveButtonTitle: "WhatsApp",
                            onTapOfPositiveButton: () {
                              // _url = "https://api.whatsapp.com/send?phone=91";
                              /* _url = "https://wa.me/";
                                                        _launchURL(model.contactNo1,_url);*/
                              Navigator.pop(context);
                              onButtonTap(Share.whatsapp_personal, model);
                            },
                            negativeButtonTitle: "Business",
                            onTapOfNegativeButton: () {
                              Navigator.pop(context);

                              _launchWhatsAppBuz(model.custmoreMobileNo);
                            });
                      },
                      child: Container(
                        /*decoration: BoxDecoration(
                                                              shape: BoxShape.rectangle,
                                                              color: colorPrimary,
                                                              borderRadius: BorderRadius.all(Radius.circular(30)),

                                                            ),*/
                        child: /*Icon(

                                                              Icons.message_sharp,
                                                              color: colorWhite,
                                                              size: 20,
                                                            )*/
                            Image.asset(
                          WHATSAPP_IMAGE,
                          width: 30,
                          height: 30,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    GestureDetector(
                      onTap: () async {
                        navigateTo(context,
                                FollowUpFromComplaintAddEditScreen.routeName,
                                arguments:
                                    AddUpdateFollowupInquiryScreenArguments(
                                        model.pkID.toString()))
                            .then((value) {
                          _complaintScreenBloc.add(ComplaintListCallEvent(
                              1,
                              ComplaintListRequest(
                                  CompanyId: CompanyID.toString(),
                                  LoginUserID: LoginUserID,
                                  SearchKey: edt_CustomerName.text)));
                        });
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                            color: colorPrimary, shape: BoxShape.circle),
                        child: Center(
                            child: Icon(
                          Icons.add,
                          size: 24,
                          color: colorWhite,
                        )),
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    GestureDetector(
                      onTap: () async {
                        MoveTofollowupHistoryPage(model.pkID.toString());
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                            color: colorWhite, shape: BoxShape.circle),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Image.asset(
                              HISTORY_ICON,
                              width: 24,
                              height: 24,
                            ),
                          ),
                        ),
                      ),
                    )
                  ]),
            ),
            Container(
                margin: EdgeInsets.all(20),
                child: Container(
                    child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text("Complaint Notes ",
                                            style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                                color: Color(label_color),
                                                fontSize: _fontSize_Label,
                                                letterSpacing: .3)),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                            model.complaintNotes == ""
                                                ? "N/A"
                                                : model.complaintNotes,
                                            style: TextStyle(
                                                color: Color(title_color),
                                                fontSize: _fontSize_Title,
                                                letterSpacing: .3)),
                                      ],
                                    )),
                              ]),
                          SizedBox(
                            height: sizeboxsize,
                          ),
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text("Mobile No.#",
                                            style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                                color: Color(label_color),
                                                fontSize: _fontSize_Label,
                                                letterSpacing: .3)),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                            model.custmoreMobileNo == null
                                                ? "N/A"
                                                : model.custmoreMobileNo,
                                            style: TextStyle(
                                                color: Color(title_color),
                                                fontSize: _fontSize_Title,
                                                letterSpacing: .3)),
                                      ],
                                    )),
                              ]),
                          SizedBox(
                            height: sizeboxsize,
                          ),
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text("Assign From",
                                            style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                                color: Color(label_color),
                                                fontSize: _fontSize_Label,
                                                letterSpacing: .3)),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                            model.createdBy == null
                                                ? "N/A"
                                                : model.createdBy,
                                            style: TextStyle(
                                                color: Color(title_color),
                                                fontSize: _fontSize_Title,
                                                letterSpacing: .3)),
                                      ],
                                    )),
                                Expanded(
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text("Assign To",
                                            style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                                color: Color(label_color),
                                                fontSize: _fontSize_Label,
                                                letterSpacing: .3)),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                            model.employeeName == null
                                                ? "N/A"
                                                : model.employeeName,
                                            style: TextStyle(
                                                color: Color(title_color),
                                                fontSize: _fontSize_Title,
                                                letterSpacing: .3)),
                                      ],
                                    )),
                              ]),
                          SizedBox(
                            height: sizeboxsize,
                          ),
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text("Status",
                                            style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                                color: Color(label_color),
                                                fontSize: _fontSize_Label,
                                                letterSpacing: .3)),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                            model.complaintStatus == null
                                                ? "N/A"
                                                : model.complaintStatus,
                                            style: TextStyle(
                                                color: model.complaintStatus ==
                                                        "Open"
                                                    ? colorGreenDark
                                                    : colorRedDark,
                                                fontSize: _fontSize_Title,
                                                letterSpacing: .3)),
                                      ],
                                    )),
                                Expanded(
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text("Sch.Time",
                                            style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                                color: Color(label_color),
                                                fontSize: _fontSize_Label,
                                                letterSpacing: .3)),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                            model.timeFrom +
                                                " - " +
                                                model.timeTo,
                                            style: TextStyle(
                                                color: Color(title_color),
                                                fontSize: _fontSize_Title,
                                                letterSpacing: .3)),
                                      ],
                                    )),
                              ]),
                          SizedBox(
                            height: sizeboxsize,
                          ),
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text("Schedule Date",
                                            style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                                color: Color(label_color),
                                                fontSize: _fontSize_Label,
                                                letterSpacing: .3)),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                            model.preferredDate == null
                                                ? "N/A"
                                                : model.preferredDate
                                                        .getFormattedDate(
                                                            fromFormat:
                                                                "yyyy-MM-ddTHH:mm:ss",
                                                            toFormat:
                                                                "dd-MM-yyyy") ??
                                                    "-",
                                            style: TextStyle(
                                                color: Color(title_color),
                                                fontSize: _fontSize_Title,
                                                letterSpacing: .3)),
                                      ],
                                    )),
                                Expanded(
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text("Complaint Date",
                                            style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                                color: Color(label_color),
                                                fontSize: _fontSize_Label,
                                                letterSpacing: .3)),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                            model.complaintDate == null
                                                ? "N/A"
                                                : model.complaintDate
                                                        .getFormattedDate(
                                                            fromFormat:
                                                                "yyyy-MM-ddTHH:mm:ss",
                                                            toFormat:
                                                                "dd-MM-yyyy") ??
                                                    "-",
                                            style: TextStyle(
                                                color: Color(title_color),
                                                fontSize: _fontSize_Title,
                                                letterSpacing: .3)),
                                      ],
                                    )),
                              ]),
                          SizedBox(
                            height: sizeboxsize,
                          ),
                        ],
                      ),
                    ),
                  ],
                ))),
            ButtonBar(
                alignment: MainAxisAlignment.center,
                buttonHeight: 52.0,
                buttonMinWidth: 90.0,
                children: <Widget>[
                  FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0)),
                    onPressed: () {
                      _complaintScreenBloc.add(
                          FetchComplaintImageListRequestEvent(
                              model,
                              FetchComplaintImageListRequest(
                                  SearchKey: model.complaintNo,
                                  ModuleName: "",
                                  DocName: "",
                                  KeyValue: model.complaintNo,
                                  CompanyID: CompanyID.toString(),
                                  LoginUserID: LoginUserID)));
                      // _onTapOfEditCustomer(model);
                    },
                    child: Column(
                      children: <Widget>[
                        Icon(
                          Icons.edit,
                          color: colorPrimary,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                        ),
                        Text(
                          'Edit',
                          style: TextStyle(color: colorPrimary),
                        ),
                      ],
                    ),
                  ),
                  isDeleteVisible == true
                      ? FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0)),
                          onPressed: () {
                            _onTapOfDeleteInquiry(model.pkID);
                          },
                          child: Column(
                            children: <Widget>[
                              Icon(
                                Icons.delete,
                                color: colorPrimary,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2.0),
                              ),
                              Text(
                                'Delete',
                                style: TextStyle(color: colorPrimary),
                              ),
                            ],
                          ),
                        )
                      : Container(),
                ]),
          ],
        ));
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    // Use `Uri` to ensure that `phoneNumber` is properly URL-encoded.
    // Just using 'tel:$phoneNumber' would create invalid URLs in some cases,
    // such as spaces in the input, which would cause `launch` to fail on some
    // platforms.
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launch(launchUri.toString());
  }

  void _launchWhatsAppBuz(String MobileNo) async {
    await launch("https://wa.me/${"+91" + MobileNo}?text=Hello");
  }

  Future<void> onButtonTap(
      Share share, ComplaintDetails customerDetails) async {
    String msg =
        "_"; //"Thank you for contacting us! We will be in touch shortly";
    //"Customer Name : "+customerDetails.customerName.toString()+"\n"+"Address : "+customerDetails.address+"\n"+"Mobile No. : " + customerDetails.contactNo1.toString();
    String url = 'https://pub.dev/packages/flutter_share_me';

    String response;
    final FlutterShareMe flutterShareMe = FlutterShareMe();
    switch (share) {
      case Share.facebook:
        response = await flutterShareMe.shareToFacebook(url: url, msg: msg);
        break;
      case Share.twitter:
        response = await flutterShareMe.shareToTwitter(url: url, msg: msg);
        break;

      case Share.whatsapp_business:
        response = await flutterShareMe.shareToWhatsApp4Biz(msg: msg);
        break;
      case Share.share_system:
        response = await flutterShareMe.shareToSystem(msg: msg);
        break;
      case Share.whatsapp_personal:
        response = await flutterShareMe.shareWhatsAppPersonalMessage(
            message: msg,
            phoneNumber: '+91' + customerDetails.custmoreMobileNo);
        break;
      case Share.share_telegram:
        response = await flutterShareMe.shareToTelegram(msg: msg);
        break;
    }
    debugPrint(response);
  }

  void _onDeleteCallSuccess(ComplaintDeleteResponseState state) {
    print("CustomerDeleted" +
        state.complaintDeleteResponse.details[0].column1.toString() +
        "");
    //baseBloc.refreshScreen();
    navigateTo(context, ComplaintPaginationListScreen.routeName,
        clearAllStack: true);
  }

  void _onTapOfDeleteInquiry(int pkID) {
    showCommonDialogWithTwoOptions(
        context, "Are you sure you want to delete this Complaint ?",
        negativeButtonTitle: "No",
        positiveButtonTitle: "Yes", onTapOfPositiveButton: () {
      Navigator.of(context).pop();
      //_collapse();
      _complaintScreenBloc.add(ComplaintDeleteCallEvent(
          pkID, ComplaintDeleteRequest(CompanyId: CompanyID.toString())));
    });
  }

  void _onSearchByIDCallSuccess(ComplaintSearchByIDResponseState state) {
    _inquiryListResponse = state.complaintSearchByIDResponse;
  }

  void _onTapOfEditCustomer(ComplaintDetails detail,
      List<FetchComplaintImageListResponseDetails> arrrImageVideoList123) {
    navigateTo(context, ComplaintAddEditScreen.routeName,
            arguments: AddUpdateComplaintScreenArguments(
                detail, arrrImageVideoList123))
        .then((value) {
      //_leaveRequestScreenBloc.add(LeaveRequestCallEvent(1,LeaveRequestListAPIRequest(EmployeeID: edt_FollowupEmployeeUserID.text,ApprovalStatus:edt_FollowupStatus.text,Month: "",Year: "",CompanyId: CompanyID )));
      _complaintScreenBloc.add(ComplaintListCallEvent(
          1,
          ComplaintListRequest(
              CompanyId: CompanyID.toString(),
              LoginUserID: LoginUserID,
              SearchKey: edt_CustomerName.text)));
    });
  }

  void _OnImageListSucess(FetchComplaintImageListResponseState state) {
    if (state.fetchComplaintImageListResponse.details.length != 0) {
      arrrImageVideoList.clear();

      for (int i = 0;
          i < state.fetchComplaintImageListResponse.details.length;
          i++) {
        if (state.fetchComplaintImageListResponse.details[i].docName != "") {
          FetchComplaintImageListResponseDetails
              fetchComplaintImageListResponseDetails =
              FetchComplaintImageListResponseDetails();

          /*

          int pkID,   String moduleName,   String keyValue,   String docName,   String docType,   String docData,   String createdBy,   String createdDate,
         */
          fetchComplaintImageListResponseDetails.pkID =
              state.fetchComplaintImageListResponse.details[i].pkID;
          fetchComplaintImageListResponseDetails.moduleName =
              state.fetchComplaintImageListResponse.details[i].moduleName;
          fetchComplaintImageListResponseDetails.keyValue =
              state.fetchComplaintImageListResponse.details[i].keyValue;
          fetchComplaintImageListResponseDetails.docName =
              state.fetchComplaintImageListResponse.details[i].docName;
          fetchComplaintImageListResponseDetails.docType =
              state.fetchComplaintImageListResponse.details[i].docType;
          fetchComplaintImageListResponseDetails.docData =
              state.fetchComplaintImageListResponse.details[i].docData;
          fetchComplaintImageListResponseDetails.createdBy =
              state.fetchComplaintImageListResponse.details[i].createdBy;
          fetchComplaintImageListResponseDetails.createdDate =
              state.fetchComplaintImageListResponse.details[i].createdDate;
          arrrImageVideoList.add(fetchComplaintImageListResponseDetails);
        }
      }
      //arrrImageVideoList.addAll(state.fetchComplaintImageListResponse.details);
      _onTapOfEditCustomer(state.complaintDetails, arrrImageVideoList);
    } else {
      _onTapOfEditCustomer(state.complaintDetails, arrrImageVideoList);
    }
  }

  Future<void> MoveTofollowupHistoryPage(String pkID) {
    navigateTo(context, ComplaintFollowupHistoryScreen.routeName,
            arguments: ComplaintFollowupHistoryScreenArguments(pkID))
        .then((value) {});
  }
}
