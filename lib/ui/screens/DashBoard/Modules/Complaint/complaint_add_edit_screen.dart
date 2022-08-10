import 'dart:io';
import 'dart:typed_data';

import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:soleoserp/blocs/base/base_bloc.dart';
import 'package:soleoserp/blocs/other/bloc_modules/complaint/complaint_bloc.dart';
import 'package:soleoserp/models/api_requests/city_list_request.dart';
import 'package:soleoserp/models/api_requests/complaint/complaint_emp_follower_list_request.dart';
import 'package:soleoserp/models/api_requests/complaint/complaint_no_to_delete_img_video_request.dart';
import 'package:soleoserp/models/api_requests/complaint/complaint_save_request.dart';
import 'package:soleoserp/models/api_requests/complaint/complaint_upload_image_request.dart';
import 'package:soleoserp/models/api_requests/country_list_request.dart';
import 'package:soleoserp/models/api_requests/customer_source_list_request.dart';
import 'package:soleoserp/models/api_requests/state_list_request.dart';
import 'package:soleoserp/models/api_responses/all_employee_List_response.dart';
import 'package:soleoserp/models/api_responses/city_api_response.dart';
import 'package:soleoserp/models/api_responses/company_details_response.dart';
import 'package:soleoserp/models/api_responses/complaint/complaint_list_response.dart';
import 'package:soleoserp/models/api_responses/complaint/fetch_complaint_image_list_response.dart';
import 'package:soleoserp/models/api_responses/customer_label_value_response.dart';
import 'package:soleoserp/models/api_responses/inquiry_product_search_response.dart';
import 'package:soleoserp/models/api_responses/login_user_details_api_response.dart';
import 'package:soleoserp/models/api_responses/state_list_response.dart';
import 'package:soleoserp/models/common/all_name_id_list.dart';
import 'package:soleoserp/models/common/globals.dart';
import 'package:soleoserp/models/common/videoList.dart';
import 'package:soleoserp/ui/res/color_resources.dart';
import 'package:soleoserp/ui/screens/DashBoard/Modules/Complaint/aspect_ratio_player.dart';
import 'package:soleoserp/ui/screens/DashBoard/Modules/Complaint/complaint_pagination_screen.dart';
import 'package:soleoserp/ui/screens/DashBoard/Modules/Complaint/search_customer_screen.dart';
import 'package:soleoserp/ui/screens/DashBoard/Modules/Customer/CustomerAdd_Edit/search_city_screen.dart';
import 'package:soleoserp/ui/screens/DashBoard/Modules/Customer/CustomerAdd_Edit/search_country_screen.dart';
import 'package:soleoserp/ui/screens/DashBoard/Modules/Customer/CustomerAdd_Edit/search_state_screen.dart';
import 'package:soleoserp/ui/screens/DashBoard/Modules/inquiry/search_inquiry_product_screen.dart';
import 'package:soleoserp/ui/screens/DashBoard/home_screen.dart';
import 'package:soleoserp/ui/screens/base/base_screen.dart';
import 'package:soleoserp/ui/widgets/common_widgets.dart';
import 'package:soleoserp/utils/General_Constants.dart';
import 'package:soleoserp/utils/datamanager.dart';
import 'package:soleoserp/utils/date_time_extensions.dart';
import 'package:soleoserp/utils/general_utils.dart';
import 'package:soleoserp/utils/image_full_screen.dart';
import 'package:soleoserp/utils/shared_pref_helper.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class AddUpdateComplaintScreenArguments {
  ComplaintDetails editModel;
  List<FetchComplaintImageListResponseDetails> arrrImageVideoList123;

  AddUpdateComplaintScreenArguments(this.editModel, this.arrrImageVideoList123);
}

class ComplaintAddEditScreen extends BaseStatefulWidget {
  static const routeName = '/ComplaintAddEditScreen';
  final AddUpdateComplaintScreenArguments arguments;

  ComplaintAddEditScreen(this.arguments);

  @override
  _ComplaintAddEditScreenState createState() => _ComplaintAddEditScreenState();
}

/*class JosKeys {
  static final cardA = GlobalKey<ExpansionTileCardState>();
  static final refreshKey  = GlobalKey<RefreshIndicatorState>();
}*/
class _ComplaintAddEditScreenState extends BaseState<ComplaintAddEditScreen>
    with BasicScreen, WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController edt_ComplanitID = TextEditingController();

  final TextEditingController edt_ComplanitDate = TextEditingController();
  final TextEditingController edt_ReverseComplanitDate =
      TextEditingController();

  final TextEditingController edt_SheduleDate = TextEditingController();
  final TextEditingController edt_ReverseSheduleDate = TextEditingController();

  final TextEditingController edt_CustomerName = TextEditingController();
  final TextEditingController edt_CustomerID = TextEditingController();

  final TextEditingController edt_Referene = TextEditingController();

  final TextEditingController edt_MobileNo = TextEditingController();
  final TextEditingController edt_SrNo = TextEditingController();

  final TextEditingController edt_ComplaintDiscription =
      TextEditingController();
  final TextEditingController edt_PreferedTime = TextEditingController();
  final TextEditingController edt_AssignTo = TextEditingController();
  final TextEditingController edt_AssignToID = TextEditingController();

  final TextEditingController edt_satus = TextEditingController();
  final TextEditingController edt_satusID = TextEditingController();

  final TextEditingController edt_Type = TextEditingController();
  final TextEditingController edt_ComplaintNotes = TextEditingController();

  final TextEditingController edt_Address = TextEditingController();

  final TextEditingController edt_FromTime = TextEditingController();
  final TextEditingController edt_ToTime = TextEditingController();

  List<ALL_Name_ID> arr_ALL_Name_ID_For_AssignTo = [];
  List<ALL_Name_ID> arr_ALL_Name_ID_For_Status = [];
  List<ALL_Name_ID> arr_ALL_Name_ID_For_Folowup_Status = [];
  List<ALL_Name_ID> arr_ALL_Name_ID_For_LeadSource = [];
  List<ALL_Name_ID> arr_ALL_Name_ID_For_Type = [];
  List<ALL_Name_ID> arr_ALL_Name_ID_For_Country = [];
  List<ALL_Name_ID> arr_ALL_Name_ID_For_State = [];
  List<ALL_Name_ID> arr_ALL_Name_ID_For_District = [];

  List<ALL_Name_ID> _listFilteredCountry = [];

  List<ALL_Name_ID> _listFilteredState = [];
  List<ALL_Name_ID> _listFilteredCity = [];

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  ComplaintScreenBloc _complaintScreenBloc;

  CompanyDetailsResponse _offlineCompanyData;
  LoginUserDetialsResponse _offlineLoggedInData;
  ALL_EmployeeList_Response _offlineALLEmployeeListData;
  SearchDetails _searchDetails;

  ProductSearchDetails _searchProductDetails;

  bool _isForUpdate;
  int CompanyID = 0;
  String LoginUserID = "";
  ComplaintDetails _editModel;

  List<FetchComplaintImageListResponseDetails> _arrrImageVideoList123 = [];
  List<FetchComplaintImageListResponseDetails> _arrrVideoList123 = [];

  int savepkID = 0;
  final TextEditingController edt_QualifiedCountry = TextEditingController();
  final TextEditingController edt_QualifiedCountryCode =
      TextEditingController();
  final TextEditingController edt_QualifiedState = TextEditingController();

  final TextEditingController edt_QualifiedStateCode = TextEditingController();
  final TextEditingController edt_QualifiedCity = TextEditingController();
  final TextEditingController edt_QualifiedCityCode = TextEditingController();

  final TextEditingController edt_Pincode = TextEditingController();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productIDController = TextEditingController();

  SearchStateDetails _searchStateDetails;
  SearchCityDetails _searchCityDetails;
  double CardViewHieght = 35;

  List<File> multiple_selectedImageFile = [];
  List<File> Tempmultiple_selectedImageFile = [];

  List<File> ALLImageVideoList = [];

  File _selectedImageFile;
  File _video;
  final picker = ImagePicker();
  VideoPlayerController _controller;

  VideoPlayerController _toBeDisposed;
  String _retrieveDataError;
  XFile videofile;
  List<File> MultipleVideoList = [];
  List<VideoListData> dataList = [];

  String VideoURLFromListing = "";

  FlickManager flickManager;
  DataManager dataManager;

  Uint8List data;
  String ImageURLFromListing = "";
  List<FetchComplaintImageListResponseDetails> arrImageList = [];

  var logger;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    logger = Logger();
    _complaintScreenBloc = ComplaintScreenBloc(baseBloc);

    _offlineLoggedInData = SharedPrefHelper.instance.getLoginUserData();
    _offlineCompanyData = SharedPrefHelper.instance.getCompanyData();
    _offlineALLEmployeeListData =
        SharedPrefHelper.instance.getALLEmployeeList();

    CompanyID = _offlineCompanyData.details[0].pkId;
    LoginUserID = _offlineLoggedInData.details[0].userID;
   // FetchAssignTODetails(_offlineALLEmployeeListData);
    FetchTypeDetails();

    _complaintScreenBloc.add(ComplaintEmpFollowerListRequestEvent(ComplaintEmpFollowerListRequest(CompanyId:CompanyID.toString(),EmployeeID: "" )));

    _isForUpdate = widget.arguments != null;
    if (_isForUpdate) {
      _editModel = widget.arguments.editModel;
      _arrrImageVideoList123 = widget.arguments.arrrImageVideoList123;
      fillData();

      //https://www.youtube.com/watch?v=BAgLOAGga2o&ab_channel=JohannesMilke
    } else {
      VideoURLFromListing = "";
      edt_ComplanitID.text = "";
      selectedDate = DateTime.now();
      edt_ComplanitDate.text = selectedDate.day.toString() +
          "-" +
          selectedDate.month.toString() +
          "-" +
          selectedDate.year.toString();
      edt_ReverseComplanitDate.text = selectedDate.year.toString() +
          "-" +
          selectedDate.month.toString() +
          "-" +
          selectedDate.day.toString();
      edt_SheduleDate.text = selectedDate.day.toString() +
          "-" +
          selectedDate.month.toString() +
          "-" +
          selectedDate.year.toString();
      edt_ReverseSheduleDate.text = selectedDate.year.toString() +
          "-" +
          selectedDate.month.toString() +
          "-" +
          selectedDate.day.toString();

      TimeOfDay selectedTime1234 = TimeOfDay.now();
      String AM_PM123 =
          selectedTime1234.periodOffset.toString() == "12" ? "PM" : "AM";
      String beforZeroHour123 = selectedTime1234.hourOfPeriod <= 9
          ? "0" + selectedTime1234.hourOfPeriod.toString()
          : selectedTime1234.hourOfPeriod.toString();
      String beforZerominute123 = selectedTime1234.minute <= 9
          ? "0" + selectedTime1234.minute.toString()
          : selectedTime1234.minute.toString();
      edt_FromTime.text = beforZeroHour123 +
          ":" +
          beforZerominute123 +
          " " +
          AM_PM123; //picked_s.periodOffset.toString();

      TimeOfDay selectedToTime =
          TimeOfDay.fromDateTime(DateTime.now().add(Duration(hours: 1)));
      String AM_PMToTime =
          selectedToTime.periodOffset.toString() == "12" ? "PM" : "AM";
      String beforZeroHourToTime = selectedToTime.hourOfPeriod <= 9
          ? "0" + selectedToTime.hourOfPeriod.toString()
          : selectedToTime.hourOfPeriod.toString();
      String beforZerominuteToTime = selectedToTime.minute <= 9
          ? "0" + selectedToTime.minute.toString()
          : selectedToTime.minute.toString();
      edt_ToTime.text = beforZeroHourToTime +
          ":" +
          beforZerominuteToTime +
          " " +
          AM_PMToTime; //picked_s.periodOffset.toString();

      /* TimeOfDay selectedTime123 = TimeOfDay.now();
      TimeOfDay newTime = TimeOfDay.fromDateTime(DateTime.now().add(Duration(hours: 1)));*/ /*selectedTime123.replacing(
          hour: selectedTime123.hour +2,
          minute: selectedTime123.minute
      );*/ /*

      String AM_PM1 = newTime.periodOffset.toString() == "12" ? "AM" : "PM";
      edt_ToTime.text = newTime.hour.toString() +
          ":" +
          newTime.minute.toString() +
          " " +
          AM_PM1; //picked_s.periodOffset.toString();*/

      edt_QualifiedCountry.text = "India";
      edt_QualifiedCountryCode.text = "IND";
      // _searchStateDetails.value = _offlineLoggedInData.details[0].stateCode;
      edt_QualifiedState.text = _offlineLoggedInData.details[0].StateName;
      edt_QualifiedStateCode.text =
          _offlineLoggedInData.details[0].stateCode.toString();

      edt_QualifiedCity.text = _offlineLoggedInData.details[0].CityName;
      edt_QualifiedCityCode.text =
          _offlineLoggedInData.details[0].CityCode.toString();

      _productNameController.text = "";
      _productIDController.text = "";

      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
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
      create: (BuildContext context) => _complaintScreenBloc..add(ComplaintEmpFollowerListRequestEvent(ComplaintEmpFollowerListRequest(CompanyId:CompanyID.toString(),EmployeeID: "" ))),
      child: BlocConsumer<ComplaintScreenBloc, ComplaintScreenStates>(
        builder: (BuildContext context, ComplaintScreenStates state) {
          /* if (state is ComplaintListResponseState) {
            _onGetListCallSuccess(state);
          }
          if (state is ComplaintSearchByIDResponseState) {
            _onSearchByIDCallSuccess(state);
          }*/
          if (state is ComplaintEmpFollowerListResponseState) {
            _onGetComplaintImageList(state);
          }
          return super.build(context);
        },
        buildWhen: (oldState, currentState) {
            if (currentState is ComplaintEmpFollowerListResponseState) {
            return true;
          }

          return false;
        },
        listener: (BuildContext context, ComplaintScreenStates state) {
          //handle states
          /* if (state is ComplaintDeleteResponseState) {
            _onDeleteCallSuccess(state);
          }*/
          if (state is CustomerSourceCallEventResponseState) {
            _onLeadSourceListTypeCallSuccess(state);
          }
          if (state is ComplaintSaveResponseState) {
            _OnComplaintSaveResponseSucess(state);
          }
          if (state is ComplaintUploadImageCallResponseState) {
            _OnComplaintImageUploadSucess(state);
          }

          if (state is CountryListEventResponseState) {
            _onCountryListSuccess(state);
          }
          if (state is StateListEventResponseState) {
            _onStateListSuccess(state);
          }
          if (state is CityListEventResponseState) {
            _onCityListSuccess(state);
          }

          if (state is ComplaintNoToDeleteImageVideoResponseState) {
            _OnImageDeleteResponse(state);
          }

          return super.build(context);
        },
        listenWhen: (oldState, currentState) {
          if (currentState is CustomerSourceCallEventResponseState ||
              currentState is ComplaintSaveResponseState ||
              currentState is CountryListEventResponseState ||
              currentState is StateListEventResponseState ||
              currentState is CityListEventResponseState ||
              currentState is ComplaintUploadImageCallResponseState ||
              currentState is ComplaintNoToDeleteImageVideoResponseState) {
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
          title: Text('Complaint Details'),
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
        body: SingleChildScrollView(
          child: Container(
              margin: EdgeInsets.all(Constant.CONTAINERMARGIN),
              child: Form(
                  key: _formKey,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _isForUpdate == true
                            ? _buildComplaintNo()
                            : Container(),
                        SizedBox(
                          width: 20,
                          height: 15,
                        ),
                        _buildFollowupDate(),
                        SizedBox(
                          width: 20,
                          height: 15,
                        ),
                        _buildBankACSearchView(),
                        SizedBox(
                          width: 20,
                          height: 15,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 10, right: 10),
                          child: Text("Mobile No.*",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: colorPrimary,
                                  fontWeight: FontWeight
                                      .bold) // baseTheme.textTheme.headline2.copyWith(color: colorBlack),

                              ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 7, right: 7, top: 10),
                          child: TextFormField(
                            controller: edt_MobileNo,
                            minLines: 1,
                            maxLines: 2,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(10.0),
                                hintText: 'Enter Number',
                                hintStyle: TextStyle(color: Colors.grey),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                )),
                          ),
                        ),
                        SizedBox(
                          width: 20,
                          height: 15,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 10, right: 10),
                          child: Text("Reference #",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: colorPrimary,
                                  fontWeight: FontWeight
                                      .bold) // baseTheme.textTheme.headline2.copyWith(color: colorBlack),

                              ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 7, right: 7, top: 10),
                          child: TextFormField(
                            controller: edt_Referene,
                            minLines: 1,
                            maxLines: 2,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(10.0),
                                hintText: 'Enter Reference #',
                                hintStyle: TextStyle(color: Colors.grey),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                )),
                          ),
                        ),
                        SizedBox(
                          width: 20,
                          height: 15,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 10, right: 10),
                          child: Text("Sr No.",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: colorPrimary,
                                  fontWeight: FontWeight
                                      .bold) // baseTheme.textTheme.headline2.copyWith(color: colorBlack),

                              ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 7, right: 7, top: 10),
                          child: TextFormField(
                            controller: edt_SrNo,
                            minLines: 1,
                            maxLines: 2,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(10.0),
                                hintText: 'Enter Number',
                                hintStyle: TextStyle(color: Colors.grey),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                )),
                          ),
                        ),
                        SizedBox(
                          width: 20,
                          height: 15,
                        ),
                        _buildProductSearchView(),
                        SizedBox(
                          width: 20,
                          height: 15,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 10, right: 10),
                          child: Text("Address",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: colorPrimary,
                                  fontWeight: FontWeight
                                      .bold) // baseTheme.textTheme.headline2.copyWith(color: colorBlack),

                              ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 7, right: 7, top: 10),
                          child: TextFormField(
                            controller: edt_Address,
                            minLines: 2,
                            maxLines: 5,
                            keyboardType: TextInputType.multiline,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(10.0),
                                hintText: 'Enter Address',
                                hintStyle: TextStyle(color: Colors.grey),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                )),
                          ),
                        ),
                        SizedBox(
                          width: 20,
                          height: 15,
                        ),
                        Row(
                          children: [
                            Expanded(flex: 1, child: QualifiedCountry()),
                            Expanded(flex: 1, child: QualifiedState()),
                          ],
                        ),
                        SizedBox(
                          width: 20,
                          height: 15,
                        ),
                        Row(
                          children: [
                            Expanded(flex: 1, child: QualifiedCity()),
                            Expanded(
                                flex: 1,
                                child: Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: Text("PinCode",
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
                                        color: colorLightGray,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        child: Container(
                                          height: CardViewHieght,
                                          padding: EdgeInsets.only(
                                              left: 20, right: 20),
                                          width: double.maxFinite,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: TextField(
                                                    controller: edt_Pincode,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    maxLength: 6,
                                                    decoration: InputDecoration(
                                                      contentPadding:
                                                          EdgeInsets.only(
                                                              bottom: 10),
                                                      counterText: "",
                                                      hintText: "PinCode",
                                                      labelStyle: TextStyle(
                                                        color:
                                                            Color(0xFF000000),
                                                      ),
                                                      border: InputBorder.none,
                                                    ),
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      color: Color(0xFF000000),
                                                    ) // baseTheme.textTheme.headline2.copyWith(color: colorBlack),
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )),
                          ],
                        ),
                        SizedBox(
                          width: 20,
                          height: 15,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 10, right: 10),
                          child: Text("Complaint Description *",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: colorPrimary,
                                  fontWeight: FontWeight
                                      .bold) // baseTheme.textTheme.headline2.copyWith(color: colorBlack),

                              ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 7, right: 7, top: 10),
                          child: TextFormField(
                            controller: edt_ComplaintNotes,
                            minLines: 2,
                            maxLines: 5,
                            keyboardType: TextInputType.multiline,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(10.0),
                                hintText: 'Enter Notes',
                                hintStyle: TextStyle(color: Colors.grey),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                )),
                          ),
                        ),
                        SizedBox(
                          width: 20,
                          height: 15,
                        ),
                        _buildNextFollowupDate(),
                        SizedBox(
                          width: 20,
                          height: 15,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 10, right: 10),
                          child: Text("Preferred Time",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: colorPrimary,
                                  fontWeight: FontWeight
                                      .bold) // baseTheme.textTheme.headline2.copyWith(color: colorBlack),

                              ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: Card(
                                    elevation: 5,
                                    color: colorLightGray,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    child: GestureDetector(
                                      onTap: () {
                                        _selectFromTime(context, edt_FromTime);
                                      },
                                      child: Container(
                                        height: 60,
                                        margin: EdgeInsets.only(
                                            left: 20, right: 10),
                                        alignment: Alignment.center,
                                        child: Row(children: [
                                          Expanded(
                                            child: TextField(
                                                enabled: false,
                                                controller: edt_FromTime,
                                                decoration: InputDecoration(
                                                  hintText: "hh:mm",
                                                  labelStyle: TextStyle(
                                                    color: Color(0xFF000000),
                                                    fontSize: 15,
                                                  ),
                                                  border: InputBorder.none,
                                                ),
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Color(0xFF000000),
                                                ) // baseTheme.textTheme.headline2.copyWith(color: colorBlack),

                                                ),
                                          ),
                                          /* Icon(
                                Icons.watch_later_outlined,
                                color: colorGrayDark,
                              )*/
                                        ]),
                                      ),
                                    )),
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Expanded(
                              child: Container(
                                child: Card(
                                    elevation: 5,
                                    color: colorLightGray,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    child: GestureDetector(
                                      onTap: () {
                                        _selectToTime(context, edt_ToTime);
                                      },
                                      child: Container(
                                        height: 60,
                                        margin: EdgeInsets.only(
                                            left: 20, right: 10),
                                        alignment: Alignment.center,
                                        child: Row(children: [
                                          Expanded(
                                            child: TextField(
                                                enabled: false,
                                                controller: edt_ToTime,
                                                decoration: InputDecoration(
                                                  hintText: "hh:mm",
                                                  labelStyle: TextStyle(
                                                    color: Color(0xFF000000),
                                                    fontSize: 15,
                                                  ),
                                                  border: InputBorder.none,
                                                ),
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Color(0xFF000000),
                                                ) // baseTheme.textTheme.headline2.copyWith(color: colorBlack),

                                                ),
                                          ),
                                          /* Icon(
                                Icons.watch_later_outlined,
                                color: colorGrayDark,
                              )*/
                                        ]),
                                      ),
                                    )),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 20,
                          height: 15,
                        ),
                        _buildEmplyeeListView(),
                        SizedBox(
                          width: 20,
                          height: 15,
                        ),
                        showcustomdialogWithID1("Status",
                            enable1: false,
                            title: "Status",
                            hintTextvalue: "Tap to Select Status",
                            icon: Icon(Icons.arrow_drop_down),
                            controllerForLeft: edt_satus,
                            controllerpkID: edt_satusID,
                            Custom_values1: arr_ALL_Name_ID_For_LeadSource),
                        CustomDropDown1("Type",
                            enable1: false,
                            title: "Type",
                            hintTextvalue: "Tap to Select Type",
                            icon: Icon(Icons.arrow_drop_down),
                            controllerForLeft: edt_Type,
                            Custom_values1: arr_ALL_Name_ID_For_Type),
                        SizedBox(
                          width: 20,
                          height: 15,
                        ),
                        uploadImage(context),
                        SizedBox(
                          width: 20,
                          height: 15,
                        ),
                        uploadVideosss(context),

                        //  uploadVideo(context),
                        SizedBox(
                          width: 20,
                          height: 15,
                        ),
                        /*              data != null
                            ? Center(
                                child: Container(
                                  margin: EdgeInsets.all(10),
                                  height: 100,
                                  width: 100,
                                  child: Center(
                                    child: ImageFullScreenWrapperWidget(
                                      child: Image.memory(data),
                                      dark: true,
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                        getCommonButton(baseTheme, () {
                          // showcustomdialogSignature(context1: context);

                          navigateTo(context, MyDigitalSignature.routeName)
                              .then((value) {
                            if (value != null) {
                              data = value;
                              setState(() {});
                            }
                          });
                        }, "Add Signature", backGroundColor: colorPrimary),
                        SizedBox(
                          width: 20,
                          height: 15,
                        ),*/
                        getCommonButton(baseTheme, () {
                          print("ComplaintDetails" +
                              "ComplaintDate : " +
                              edt_ComplanitDate.text +
                              " ComplaintReverseDate : " +
                              edt_ReverseComplanitDate.text +
                              " CustomerName : " +
                              edt_CustomerName.text +
                              " Customer ID : " +
                              edt_CustomerID.text +
                              " Reference : " +
                              edt_Referene.text +
                              " ComplaintNotes : " +
                              edt_ComplaintNotes.text +
                              " SheduleDate : " +
                              edt_SheduleDate.text +
                              " ReverseSheduleDate : " +
                              edt_ReverseSheduleDate.text +
                              " FromTime : " +
                              edt_FromTime.text +
                              " ToTime : " +
                              edt_ToTime.text +
                              " AssignTo : " +
                              edt_AssignTo.text +
                              " AssignToID : " +
                              edt_AssignToID.text +
                              " Status : " +
                              edt_satus.text +
                              " StatusID : " +
                              edt_satusID.text +
                              " Type : " +
                              edt_Type.text +
                              "");

                          if (edt_CustomerName.text != "") {
                            if (edt_MobileNo.text != "") {
                              if (edt_ComplaintNotes.text != "") {
                                if (edt_SheduleDate.text != "") {
                                  if (edt_AssignTo.text != "") {
                                    print("sljdrte" +
                                        " Image List : " +
                                        multiple_selectedImageFile.length
                                            .toString() +
                                        " VideoList : " +
                                        MultipleVideoList.length.toString());
                                    ALLImageVideoList.clear();
                                    ALLImageVideoList.addAll(
                                        multiple_selectedImageFile);
                                    ALLImageVideoList.addAll(MultipleVideoList);

                                    print("dfjdfdj" +
                                        " ALLImageVideoList : " +
                                        ALLImageVideoList.length.toString());

                                    DateTime FbrazilianDate =
                                        new DateFormat("dd-MM-yyyy")
                                            .parse(edt_ComplanitDate.text);
                                    DateTime NbrazilianDate =
                                        new DateFormat("dd-MM-yyyy")
                                            .parse(edt_SheduleDate.text);

                                    if (FbrazilianDate.isBefore(
                                        NbrazilianDate)) {
                                      showCommonDialogWithTwoOptions(context,
                                          "Are you sure you want to Save this Complaint Details ?",
                                          negativeButtonTitle: "No",
                                          positiveButtonTitle: "Yes",
                                          onTapOfPositiveButton: () {
                                        Navigator.of(context).pop();
                                        _complaintScreenBloc
                                            .add(ComplaintSaveCallEvent(
                                                savepkID,
                                                ComplaintSaveRequest(
                                                  ComplaintDate:
                                                      edt_ReverseComplanitDate
                                                          .text,
                                                  ComplaintNo:
                                                      edt_ComplanitID.text,
                                                  CustomerEmpName:
                                                      edt_CustomerName.text,
                                                  ReferenceName:
                                                      edt_Referene.text == null
                                                          ? ""
                                                          : edt_Referene.text,
                                                  ComplaintNotes:
                                                      edt_ComplaintNotes.text,
                                                  ComplaintType:
                                                      edt_Type.text == null
                                                          ? ""
                                                          : edt_Type.text,
                                                  ComplaintStatus:
                                                      edt_satus.text == null
                                                          ? ""
                                                          : edt_satus.text,
                                                  EmployeeID:
                                                      edt_AssignToID.text,
                                                  PreferredDate:
                                                      edt_ReverseSheduleDate
                                                          .text,
                                                  TimeFrom: edt_FromTime.text,
                                                  TimeTo: edt_ToTime.text,
                                                  LoginUserID: LoginUserID,
                                                  CompanyId:
                                                      CompanyID.toString(),
                                                  CustmoreMobileNo:
                                                      edt_MobileNo.text,
                                                  DateOfPurchase: selectedDate
                                                          .year
                                                          .toString() +
                                                      "-" +
                                                      selectedDate.month
                                                          .toString() +
                                                      "-" +
                                                      selectedDate.day
                                                          .toString(),
                                                  SiteAddress: edt_Address.text,
                                                  CityCode:
                                                      edt_QualifiedCityCode
                                                          .text,
                                                  CountryCode:
                                                      edt_QualifiedCountryCode
                                                          .text,
                                                  StateCode:
                                                      edt_QualifiedStateCode
                                                          .text,
                                                  Pincode: edt_Pincode.text,
                                                  ConvinientDate: selectedDate
                                                          .year
                                                          .toString() +
                                                      "-" +
                                                      selectedDate.month
                                                          .toString() +
                                                      "-" +
                                                      selectedDate.day
                                                          .toString(),
                                                  ProductID:
                                                      _productIDController.text,
                                                  SrNo: edt_SrNo.text,
                                                )));
                                      });
                                    } else {
                                      if (FbrazilianDate.isAtSameMomentAs(
                                          NbrazilianDate)) {
                                        showCommonDialogWithTwoOptions(context,
                                            "Are you sure you want to Save this Complaint Details ?",
                                            negativeButtonTitle: "No",
                                            positiveButtonTitle: "Yes",
                                            onTapOfPositiveButton: () {
                                          Navigator.of(context).pop();
                                          _complaintScreenBloc
                                              .add(ComplaintSaveCallEvent(
                                                  savepkID,
                                                  ComplaintSaveRequest(
                                                    ComplaintDate:
                                                        edt_ReverseComplanitDate
                                                            .text,
                                                    ComplaintNo:
                                                        edt_ComplanitID.text,
                                                    CustomerEmpName:
                                                        edt_CustomerName.text,
                                                    ReferenceName:
                                                        edt_Referene.text ==
                                                                null
                                                            ? ""
                                                            : edt_Referene.text,
                                                    ComplaintNotes:
                                                        edt_ComplaintNotes.text,
                                                    ComplaintType:
                                                        edt_Type.text == null
                                                            ? ""
                                                            : edt_Type.text,
                                                    ComplaintStatus:
                                                        edt_satus.text == null
                                                            ? ""
                                                            : edt_satus.text,
                                                    EmployeeID:
                                                        edt_AssignToID.text,
                                                    PreferredDate:
                                                        edt_ReverseSheduleDate
                                                            .text,
                                                    TimeFrom: edt_FromTime.text,
                                                    TimeTo: edt_ToTime.text,
                                                    LoginUserID: LoginUserID,
                                                    CompanyId:
                                                        CompanyID.toString(),
                                                    CustmoreMobileNo:
                                                        edt_MobileNo.text,
                                                    DateOfPurchase: selectedDate
                                                            .year
                                                            .toString() +
                                                        "-" +
                                                        selectedDate.month
                                                            .toString() +
                                                        "-" +
                                                        selectedDate.day
                                                            .toString(),
                                                    SiteAddress:
                                                        edt_Address.text,
                                                    CityCode:
                                                        edt_QualifiedCityCode
                                                            .text,
                                                    CountryCode:
                                                        edt_QualifiedCountryCode
                                                            .text,
                                                    StateCode:
                                                        edt_QualifiedStateCode
                                                            .text,
                                                    Pincode: edt_Pincode.text,
                                                    ConvinientDate: selectedDate
                                                            .year
                                                            .toString() +
                                                        "-" +
                                                        selectedDate.month
                                                            .toString() +
                                                        "-" +
                                                        selectedDate.day
                                                            .toString(),
                                                    ProductID:
                                                        _productIDController
                                                            .text,
                                                    SrNo: edt_SrNo.text,
                                                  )));
                                        });
                                      } else {
                                        showCommonDialogWithSingleOption(
                                            context,
                                            "Schedule Date Should be greater than Complaint Date !",
                                            positiveButtonTitle: "OK",
                                            onTapOfPositiveButton: () {
                                          Navigator.of(context).pop();
                                        });
                                      }
                                    }
                                  } else {
                                    showCommonDialogWithSingleOption(
                                        context, "Assign To is required !",
                                        onTapOfPositiveButton: () {
                                      Navigator.of(context).pop();
                                    });
                                  }
                                } else {
                                  showCommonDialogWithSingleOption(
                                      context, "Schedule Date is required !",
                                      onTapOfPositiveButton: () {
                                    Navigator.of(context).pop();
                                  });
                                }
                              } else {
                                showCommonDialogWithSingleOption(
                                    context, "Complaint Notes is required !",
                                    onTapOfPositiveButton: () {
                                  Navigator.of(context).pop();
                                });
                              }
                            } else {
                              showCommonDialogWithSingleOption(
                                  context, "Mobile No. is required !",
                                  onTapOfPositiveButton: () {
                                Navigator.of(context).pop();
                              });
                            }
                          } else {
                            showCommonDialogWithSingleOption(
                                context, "Customer name is required !",
                                onTapOfPositiveButton: () {
                              Navigator.of(context).pop();
                            });
                          }
                        }, "Save", backGroundColor: colorPrimary),
                        SizedBox(
                          width: 20,
                          height: 15,
                        ),
                      ]))),
        ),
      ),
    );
  }

  Widget CustomDropDown1(String Category,
      {bool enable1,
      Icon icon,
      String title,
      String hintTextvalue,
      TextEditingController controllerForLeft,
      List<ALL_Name_ID> Custom_values1}) {
    return Container(
      margin: EdgeInsets.only(top: 15, bottom: 15),
      child: Column(
        children: [
          InkWell(
            onTap: () => showcustomdialogWithOnlyName(
                values: arr_ALL_Name_ID_For_Type,
                context1: context,
                controller: controllerForLeft,
                lable: "Select $Category"),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  child: Text(title,
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
                  color: colorLightGray,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Container(
                    height: 60,
                    padding: EdgeInsets.only(left: 20, right: 20),
                    width: double.maxFinite,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                              controller: controllerForLeft,
                              enabled: false,
                              decoration: InputDecoration(
                                hintText: hintTextvalue,
                                labelStyle: TextStyle(
                                  color: Color(0xFF000000),
                                ),
                                border: InputBorder.none,
                              ),
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF000000),
                              ) // baseTheme.textTheme.headline2.copyWith(color: colorBlack),

                              ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: colorGrayDark,
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget showcustomdialogWithID1(String Category,
      {bool enable1,
      Icon icon,
      String title,
      String hintTextvalue,
      TextEditingController controllerForLeft,
      TextEditingController controller1,
      TextEditingController controllerpkID,
      List<ALL_Name_ID> Custom_values1}) {
    return Container(
      child: Column(
        children: [
          InkWell(
            onTap: () => _complaintScreenBloc.add(CustomerSourceCallEvent(
                CustomerSourceRequest(
                    pkID: "0",
                    StatusCategory: "ComplaintStatus",
                    companyId: CompanyID,
                    LoginUserID: LoginUserID,
                    SearchKey: ""))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  child: Text(title,
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
                  color: colorLightGray,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Container(
                    height: 60,
                    padding: EdgeInsets.only(left: 20, right: 20),
                    width: double.maxFinite,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                              controller: controllerForLeft,
                              enabled: false,
                              decoration: InputDecoration(
                                hintText: hintTextvalue,
                                labelStyle: TextStyle(
                                  color: Color(0xFF000000),
                                ),
                                border: InputBorder.none,
                              ),
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF000000),
                              ) // baseTheme.textTheme.headline2.copyWith(color: colorBlack),

                              ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: colorGrayDark,
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmplyeeListView() {
    return InkWell(
      onTap: () {
        // _onTapOfSearchView(context);
        showcustomdialogWithID(
            values: arr_ALL_Name_ID_For_AssignTo,
            context1: context,
            controller: edt_AssignTo,
            controllerID: edt_AssignToID,
            lable: "Select AssignTo");
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(left: 5),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Assigned To *",
                  style: TextStyle(
                      fontSize: 12,
                      color: colorPrimary,
                      fontWeight: FontWeight
                          .bold) // baseTheme.textTheme.headline2.copyWith(color: colorBlack),

                  ),
              /* Icon(
                Icons.filter_list_alt,
                color: colorPrimary,
              ),*/
            ]),
          ),
          SizedBox(
            height: 5,
          ),
          Card(
            elevation: 5,
            color: colorLightGray,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Container(
              padding: EdgeInsets.only(top: 5, bottom: 5, left: 5, right: 10),
              width: double.maxFinite,
              child: Row(
                children: [
                  Expanded(
                    child: /* Text(
                        SelectedStatus =="" ?
                        "Tap to select Status" : SelectedStatus.Name,
                        style:TextStyle(fontSize: 12,color: Color(0xFF000000),fontWeight: FontWeight.bold)// baseTheme.textTheme.headline2.copyWith(color: colorBlack),

                    ),*/

                        TextField(
                      controller: edt_AssignTo,
                      enabled: false,
                      /*  onChanged: (value) => {
                    print("StatusValue " + value.toString() )
                },*/
                      style: TextStyle(
                          color: Colors.black, // <-- Change this

                          fontSize: 15),
                      decoration: new InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding: EdgeInsets.only(
                              left: 15, bottom: 11, top: 11, right: 15),
                          hintText: "Select Employee"),
                    ),
                    // dropdown()
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: colorGrayDark,
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _selectFromTime(
      BuildContext context, TextEditingController F_datecontroller) async {
    final TimeOfDay picked_s = await showTimePicker(
        context: context,
        initialTime: selectedTime,
        builder: (BuildContext context, Widget child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child,
          );
        });

    if (picked_s != null && picked_s != selectedTime)
      setState(() {
        selectedTime = picked_s;

        String AM_PM =
            selectedTime.periodOffset.toString() == "12" ? "PM" : "AM";
        String beforZeroHour = selectedTime.hourOfPeriod <= 9
            ? "0" + selectedTime.hourOfPeriod.toString()
            : selectedTime.hourOfPeriod.toString();
        String beforZerominute = selectedTime.minute <= 9
            ? "0" + selectedTime.minute.toString()
            : selectedTime.minute.toString();

        edt_FromTime.text = beforZeroHour +
            ":" +
            beforZerominute +
            " " +
            AM_PM; //picked_s.periodOffset.toString();
      });
  }

  Future<void> _selectToTime(
      BuildContext context, TextEditingController F_datecontroller) async {
    final TimeOfDay picked_s = await showTimePicker(
        context: context,
        initialTime: selectedTime,
        builder: (BuildContext context, Widget child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child,
          );
        });

    if (picked_s != null && picked_s != selectedTime)
      setState(() {
        selectedTime = picked_s;

        String AM_PM =
            selectedTime.periodOffset.toString() == "12" ? "PM" : "AM";
        String beforZeroHour = selectedTime.hourOfPeriod <= 9
            ? "0" + selectedTime.hourOfPeriod.toString()
            : selectedTime.hourOfPeriod.toString();
        String beforZerominute = selectedTime.minute <= 9
            ? "0" + selectedTime.minute.toString()
            : selectedTime.minute.toString();

        edt_ToTime.text = beforZeroHour +
            ":" +
            beforZerominute +
            " " +
            AM_PM; //picked_s.periodOffset.toString();
      });
  }

  Widget _buildNextFollowupDate() {
    return InkWell(
      onTap: () {
        _selectNextFollowupDate(context, edt_SheduleDate);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(left: 10, right: 10),
            child: Text("Schedule Date *",
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
            color: colorLightGray,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Container(
              height: 60,
              padding: EdgeInsets.only(left: 20, right: 20),
              width: double.maxFinite,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      edt_SheduleDate.text == null || edt_SheduleDate.text == ""
                          ? "DD-MM-YYYY"
                          : edt_SheduleDate.text,
                      style: baseTheme.textTheme.headline3.copyWith(
                          color: edt_SheduleDate.text == null ||
                                  edt_SheduleDate.text == ""
                              ? colorGrayDark
                              : colorBlack),
                    ),
                  ),
                  Icon(
                    Icons.calendar_today_outlined,
                    color: colorGrayDark,
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _selectNextFollowupDate(
      BuildContext context, TextEditingController F_datecontroller) async {
    DateTime selectedDate = DateTime.now();

    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: selectedDate,
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        edt_SheduleDate.text = selectedDate.day.toString() +
            "-" +
            selectedDate.month.toString() +
            "-" +
            selectedDate.year.toString();
        edt_ReverseSheduleDate.text = selectedDate.year.toString() +
            "-" +
            selectedDate.month.toString() +
            "-" +
            selectedDate.day.toString();
      });
  }

  Widget _buildFollowupDate() {
    return InkWell(
      onTap: () {
        _selectDate(context, edt_ComplanitDate);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(left: 10, right: 10),
            child: Text("Complaint Date *",
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
            color: colorLightGray,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Container(
              height: 60,
              padding: EdgeInsets.only(left: 20, right: 20),
              width: double.maxFinite,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      edt_ComplanitDate.text == null ||
                              edt_ComplanitDate.text == ""
                          ? "DD-MM-YYYY"
                          : edt_ComplanitDate.text,
                      style: baseTheme.textTheme.headline3.copyWith(
                          color: edt_ComplanitDate.text == null ||
                                  edt_ComplanitDate.text == ""
                              ? colorGrayDark
                              : colorBlack),
                    ),
                  ),
                  Icon(
                    Icons.calendar_today_outlined,
                    color: colorGrayDark,
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildComplaintNo() {
    return InkWell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(left: 10, right: 10),
            child: Text("Complaint No",
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
            color: colorLightGray,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Container(
              height: 60,
              padding: EdgeInsets.only(left: 20, right: 20),
              width: double.maxFinite,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      edt_ComplanitID.text == null || edt_ComplanitID.text == ""
                          ? "Complaint No."
                          : edt_ComplanitID.text,
                      style: baseTheme.textTheme.headline3.copyWith(
                          color: edt_ComplanitID.text == null ||
                                  edt_ComplanitID.text == ""
                              ? colorGrayDark
                              : colorBlack),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController F_datecontroller) async {
    DateTime selectedDate = DateTime.now();

    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        edt_ComplanitDate.text = selectedDate.day.toString() +
            "-" +
            selectedDate.month.toString() +
            "-" +
            selectedDate.year.toString();
        edt_ReverseComplanitDate.text = selectedDate.year.toString() +
            "-" +
            selectedDate.month.toString() +
            "-" +
            selectedDate.day.toString();
      });
  }

  Widget _buildBankACSearchView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(left: 10, right: 10),
          child: Text("Customer Name * ",
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
          color: colorLightGray,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Container(
            height: 60,
            padding: EdgeInsets.only(left: 20, right: 20),
            width: double.maxFinite,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                      controller: edt_CustomerName,
                      decoration: InputDecoration(
                        hintText: "Search Customer",
                        labelStyle: TextStyle(
                          color: Color(0xFF000000),
                        ),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF000000),
                      ) // baseTheme.textTheme.headline2.copyWith(color: colorBlack),

                      ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Future<void> _onTapOfBankACSearchView() async {
    if (_isForUpdate == false) {
      navigateTo(context, SearchComplaintCustomerScreen.routeName)
          .then((value) {
        if (value != null) {
          _searchDetails = value;
          edt_CustomerID.text = _searchDetails.value.toString();
          edt_CustomerName.text = _searchDetails.label.toString();
          edt_QualifiedCountryCode.text = _searchDetails.countryCode.toString();
          edt_QualifiedCountry.text = _searchDetails.countryName.toString();
          edt_QualifiedStateCode.text = _searchDetails.stateCode.toString();
          edt_QualifiedState.text = _searchDetails.stateName.toString();
          edt_QualifiedCity.text = _searchDetails.CityName.toString();
          edt_QualifiedCityCode.text = _searchDetails.CityCode.toString();

          /*  _FollowupBloc.add(SearchBankVoucherCustomerListByNameCallEvent(
              CustomerLabelValueRequest(
                  CompanyId: CompanyID.toString(),
                  LoginUserID: "admin",
                  word: _searchDetails.value.toString())));*/

        }
        print("CustomerInfo : " +
            edt_CustomerName.text.toString() +
            " CustomerID : " +
            edt_CustomerID.text.toString());
      });
    }
  }

  Future<bool> _onBackPressed() {
    navigateTo(context, ComplaintPaginationListScreen.routeName,
        clearAllStack: true);
  }

  FetchAssignTODetails(ALL_EmployeeList_Response offlineALLEmployeeListData) {
    arr_ALL_Name_ID_For_AssignTo.clear();
    for (var i = 0; i < offlineALLEmployeeListData.details.length; i++) {
      ALL_Name_ID all_name_id = ALL_Name_ID();

      all_name_id.Name = offlineALLEmployeeListData.details[i].employeeName;
      all_name_id.pkID = offlineALLEmployeeListData.details[i].pkID;

      arr_ALL_Name_ID_For_AssignTo.add(all_name_id);
    }
  }

  void fillData() {
    if (_editModel.complaintDate == "") {
      selectedDate = DateTime.now();
      edt_ComplanitDate.text = selectedDate.day.toString() +
          "-" +
          selectedDate.month.toString() +
          "-" +
          selectedDate.year.toString();
      edt_ReverseComplanitDate.text = selectedDate.year.toString() +
          "-" +
          selectedDate.month.toString() +
          "-" +
          selectedDate.day.toString();
    } else {
      edt_ComplanitDate.text = _editModel.complaintDate.getFormattedDate(
          fromFormat: "yyyy-MM-ddTHH:mm:ss", toFormat: "dd-MM-yyyy");
      edt_ReverseComplanitDate.text = _editModel.complaintDate.getFormattedDate(
          fromFormat: "yyyy-MM-ddTHH:mm:ss", toFormat: "yyyy-MM-dd");
    }
    if (_editModel.preferredDate == "") {
      selectedDate = DateTime.now();

      edt_SheduleDate.text = selectedDate.day.toString() +
          "-" +
          selectedDate.month.toString() +
          "-" +
          selectedDate.year.toString();
      edt_ReverseSheduleDate.text = selectedDate.year.toString() +
          "-" +
          selectedDate.month.toString() +
          "-" +
          selectedDate.day.toString();
    } else {
      edt_SheduleDate.text = _editModel.preferredDate.getFormattedDate(
          fromFormat: "yyyy-MM-ddTHH:mm:ss", toFormat: "dd-MM-yyyy");
      edt_ReverseSheduleDate.text = _editModel.preferredDate.getFormattedDate(
          fromFormat: "yyyy-MM-ddTHH:mm:ss", toFormat: "yyyy-MM-dd");
    }
    savepkID = _editModel.pkID.toInt();
    edt_CustomerName.text = _editModel.customerName;
    //edt_CustomerID.text = _editModel..toString();
    edt_Referene.text = _editModel.referenceName;
    edt_ComplaintNotes.text = _editModel.complaintNotes;

    if (_editModel.timeFrom == "") {
      TimeOfDay selectedTime1234 = TimeOfDay.now();
      String AM_PM123 =
          selectedTime1234.periodOffset.toString() == "12" ? "PM" : "AM";
      String beforZeroHour123 = selectedTime1234.hourOfPeriod <= 9
          ? "0" + selectedTime1234.hourOfPeriod.toString()
          : selectedTime1234.hourOfPeriod.toString();
      String beforZerominute123 = selectedTime1234.minute <= 9
          ? "0" + selectedTime1234.minute.toString()
          : selectedTime1234.minute.toString();
      edt_FromTime.text = beforZeroHour123 +
          ":" +
          beforZerominute123 +
          " " +
          AM_PM123; //picked_s.periodOffset.toString();

    } else {
      edt_FromTime.text = _editModel.timeFrom.getFormattedDate(
          fromFormat: "yyyy-MM-ddTHH:mm:ss", toFormat: "hh:mm a");
    }
    if (_editModel.timeTo == "") {
      TimeOfDay selectedToTime =
          TimeOfDay.fromDateTime(DateTime.now().add(Duration(hours: 1)));
      String AM_PMToTime =
          selectedToTime.periodOffset.toString() == "12" ? "PM" : "AM";
      String beforZeroHourToTime = selectedToTime.hourOfPeriod <= 9
          ? "0" + selectedToTime.hourOfPeriod.toString()
          : selectedToTime.hourOfPeriod.toString();
      String beforZerominuteToTime = selectedToTime.minute <= 9
          ? "0" + selectedToTime.minute.toString()
          : selectedToTime.minute.toString();
      edt_ToTime.text =
          beforZeroHourToTime + ":" + beforZerominuteToTime + " " + AM_PMToTime;
    } else {
      edt_ToTime.text = _editModel.timeTo.getFormattedDate(
          fromFormat: "yyyy-MM-ddTHH:mm:ss", toFormat: "hh:mm a");
    }

    //selectedInTime =

    edt_AssignTo.text = _editModel.employeeName;
    edt_AssignToID.text = _editModel.employeeID.toString();
    edt_satus.text =
        _editModel.complaintStatus == "0" ? "" : _editModel.complaintStatus;
    edt_Type.text = _editModel.complaintType;
    edt_ComplanitID.text = _editModel.complaintNo;
    // VideoURLFromListing = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4";
    //"https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4";

    if (_editModel.productName != "") {
      if (_editModel.productName != "--Not Available--") {
        _productNameController.text = _editModel.productName;
        _productIDController.text = _editModel.productID.toString();
      } else {
        _productNameController.text = "";
        _productIDController.text = "";
      }
    } else {
      _productNameController.text = "";
      _productIDController.text = "";
    }

    edt_SrNo.text = _editModel.srNo;
    edt_MobileNo.text = _editModel.custmoreMobileNo;
    edt_Address.text = _editModel.siteAddress;

    edt_QualifiedCountry.text = _editModel.countryName;
    edt_QualifiedCountryCode.text = _editModel.countryCode;
    edt_QualifiedState.text = _editModel.stateName;
    edt_QualifiedStateCode.text = _editModel.stateCode.toString();
    edt_QualifiedCity.text = _editModel.cityName.toString();
    edt_QualifiedCityCode.text = _editModel.cityCode.toString();
    edt_Pincode.text = _editModel.pincode.toString();

    /*if (_editModel.complaintNo != "") {
      Tempmultiple_selectedImageFile.clear();
      _complaintScreenBloc.add(FetchComplaintImageListRequestEvent(
          FetchComplaintImageListRequest(
              SearchKey: _editModel.complaintNo,
              ModuleName: "",
              DocName: "",
              KeyValue: _editModel.complaintNo,
              CompanyID: CompanyID.toString(),
              LoginUserID: LoginUserID)));
    }*/

    for (int i = 0; i < _arrrImageVideoList123.length; i++) {
      print("ImageNameList" +
          " Image : " +
          _arrrImageVideoList123[i].docName.toString());
      ImageURLFromListing = _offlineCompanyData.details[0].siteURL +
          "/ModuleDocs/" +
          _arrrImageVideoList123[i].docName.toString();

      print("FileExtention" +
          " File Type : " +
          _arrrImageVideoList123[i].docName.split(".").last);

      if (_arrrImageVideoList123[i].docName != "") {
        if (_arrrImageVideoList123[i].docName.split(".").last == "jpg" ||
            _arrrImageVideoList123[i].docName.split(".").last == "png") {
          getDetailsOfImage(ImageURLFromListing,
              _arrrImageVideoList123[i].docName.toString());
        } else {
          getDetailsOfVideo(ImageURLFromListing,
              _arrrImageVideoList123[i].docName.toString());
        }
        setState(() {});
      }
    }
  }

  void _onLeadSourceListTypeCallSuccess(
      CustomerSourceCallEventResponseState state) {
    if (state.sourceResponse.details.length != 0) {
      arr_ALL_Name_ID_For_LeadSource.clear();
      for (var i = 0; i < state.sourceResponse.details.length; i++) {
        print(
            "InquiryStatus : " + state.sourceResponse.details[i].inquiryStatus);
        ALL_Name_ID all_name_id = ALL_Name_ID();
        all_name_id.Name = state.sourceResponse.details[i].inquiryStatus;
        all_name_id.pkID = state.sourceResponse.details[i].pkID;
        arr_ALL_Name_ID_For_LeadSource.add(all_name_id);
      }
      showcustomdialogWithID(
          values: arr_ALL_Name_ID_For_LeadSource,
          context1: context,
          controller: edt_satus,
          controllerID: edt_satusID,
          lable: "Select Status");
    }
  }

  FetchTypeDetails() {
    arr_ALL_Name_ID_For_Type.clear();
    for (var i = 0; i <= 1; i++) {
      ALL_Name_ID all_name_id = ALL_Name_ID();

      if (i == 0) {
        all_name_id.Name = "Online";
      } else if (i == 1) {
        all_name_id.Name = "Offline";
      }
      arr_ALL_Name_ID_For_Type.add(all_name_id);
    }
  }

  void _OnComplaintSaveResponseSucess(ComplaintSaveResponseState state) async {
    String Msg = "";

    var splitNo = state.complaintSaveResponse.details[0].column3.split(",");
    print("CONO" + " Co.Number : " + splitNo[0] + " pkID : " + splitNo[1]);
/*    for (var i = 0; i < state.complaintSaveResponse.details.length; i++) {
      print("SAveSucesss" + state.complaintSaveResponse.details[i].column2);
      Msg = _isForUpdate == true
          ? "Complaint Updated Successfully"
          : "Complaint Added Successfully";
    }
    await showCommonDialogWithSingleOption(Globals.context, Msg,
        positiveButtonTitle: "OK", onTapOfPositiveButton: () {
      navigateTo(context, ComplaintPaginationListScreen.routeName,
          clearAllStack: true);
    });*/
    if (edt_ComplanitID.text != "") {
      _complaintScreenBloc.add(ComplaintNoToDeleteImageVideoRequestEvent(
          edt_ComplanitID.text,
          ComplaintNoToDeleteImageVideoRequest(
              CompanyId: CompanyID.toString(), LoginUserID: LoginUserID)));
    }

    if (ALLImageVideoList.length != 0) {
      _complaintScreenBloc.add(ComplaintUploadImageNameCallEvent(
          ALLImageVideoList,
          ComplaintUploadImageAPIRequest(
              ModuleName: "complaint",
              DocName: ALLImageVideoList[0].path.split('/').last,
              KeyValue: splitNo[0],
              LoginUserId: LoginUserID,
              CompanyId: CompanyID.toString(),
              pkID: splitNo[1],
              file: ALLImageVideoList[0])));
    } else {
      String Msg = _isForUpdate == true
          ? "Complaint Updated Successfully"
          : "Complaint Added Successfully";

      await showCommonDialogWithSingleOption(Globals.context, Msg,
          positiveButtonTitle: "OK", onTapOfPositiveButton: () {
        navigateTo(context, ComplaintPaginationListScreen.routeName,
            clearAllStack: true);
      });
    }
  }

  Widget QualifiedCountry() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(left: 10, right: 10),
          child: Text("Country *",
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
        InkWell(
            onTap: () => _onTapOfSearchCountryView(""),
            child: Card(
              elevation: 5,
              color: colorLightGray,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Container(
                height: CardViewHieght,
                padding: EdgeInsets.only(left: 20, right: 20),
                width: double.maxFinite,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                          enabled: false,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          controller: edt_QualifiedCountry,
                          decoration: InputDecoration(
                            //contentPadding: EdgeInsets.only(bottom: 10),
                            contentPadding: EdgeInsets.only(bottom: 10),

                            hintText: "Country",
                            labelStyle: TextStyle(
                              color: Color(0xFF000000),
                            ),
                            border: InputBorder.none,
                          ),
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF000000),
                          ) // baseTheme.textTheme.headline2.copyWith(color: colorBlack),

                          ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Future<void> _onTapOfSearchCountryView(String sw) async {
    navigateTo(context, SearchCountryScreen.routeName,
            arguments: CountryArguments(sw))
        .then((value) {
      if (value != null) {
        //_searchDetails = SearchDetails();
        //_searchDetails = value;
        print("CountryName IS From SearchList" + value.countryCode);
        edt_QualifiedCountryCode.text = value.countryCode;
        edt_QualifiedCountry.text = value.countryName;
        _complaintScreenBloc.add(CountryCallEvent(CountryListRequest(
            CountryCode: value.countryCode, CompanyID: CompanyID.toString())));
      }
    });
  }

  Widget QualifiedState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(left: 10, right: 10),
          child: Text("State * ",
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
        InkWell(
          onTap: () => _onTapOfSearchStateView(
              edt_QualifiedCountryCode.text == ""
                  ? ""
                  : edt_QualifiedCountryCode.text),
          child: Card(
            elevation: 5,
            color: colorLightGray,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Container(
              height: CardViewHieght,
              padding: EdgeInsets.only(left: 20, right: 20),
              width: double.maxFinite,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                        enabled: false,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        controller: edt_QualifiedState,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(bottom: 10),
                          hintText: "State",
                          labelStyle: TextStyle(
                            color: Color(0xFF000000),
                          ),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF000000),
                        ) // baseTheme.textTheme.headline2.copyWith(color: colorBlack),

                        ),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Future<void> _onTapOfSearchStateView(String sw1) async {
    navigateTo(context, SearchStateScreen.routeName,
            arguments: StateArguments(sw1))
        .then((value) {
      if (value != null) {
        _searchStateDetails = value;
        edt_QualifiedStateCode.text = _searchStateDetails.value.toString();
        edt_QualifiedState.text = _searchStateDetails.label.toString();
        _complaintScreenBloc.add(StateCallEvent(StateListRequest(
            CountryCode: sw1,
            CompanyId: CompanyID.toString(),
            word: "",
            Search: "1")));
      }
    });
  }

  Widget QualifiedCity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(left: 10, right: 10),
          child: Text("City * ",
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
        InkWell(
          onTap: () => _onTapOfSearchCityView(
              edt_QualifiedStateCode.text == null
                  ? ""
                  : edt_QualifiedStateCode.text.toString()),
          child: Card(
            elevation: 5,
            color: colorLightGray,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Container(
              height: CardViewHieght,
              padding: EdgeInsets.only(left: 20, right: 20),
              width: double.maxFinite,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                        enabled: false,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        controller: edt_QualifiedCity,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(bottom: 10),
                          hintText: "City",
                          labelStyle: TextStyle(
                            color: Color(0xFF000000),
                          ),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF000000),
                        ) // baseTheme.textTheme.headline2.copyWith(color: colorBlack),

                        ),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Future<void> _onTapOfSearchCityView(String talukaCode) async {
    navigateTo(context, SearchCityScreen.routeName,
            arguments: CityArguments(talukaCode))
        .then((value) {
      if (value != null) {
        _searchCityDetails = value;
        edt_QualifiedCityCode.text = _searchCityDetails.cityCode.toString();
        edt_QualifiedCity.text = _searchCityDetails.cityName.toString();
        _complaintScreenBloc
          ..add(CityCallEvent(CityApiRequest(
              CityName: "",
              CompanyID: CompanyID.toString(),
              StateCode: talukaCode)));
      }
    });
  }

  void _onCountryListSuccess(CountryListEventResponseState responseState) {
    arr_ALL_Name_ID_For_Country.clear();
    for (var i = 0; i < responseState.countrylistresponse.details.length; i++) {
      print("CustomerCategoryResponse2 : " +
          responseState.countrylistresponse.details[i].countryName);
      ALL_Name_ID categoryResponse123 = ALL_Name_ID();
      categoryResponse123.Name =
          responseState.countrylistresponse.details[i].countryName;
      categoryResponse123.Name1 =
          responseState.countrylistresponse.details[i].countryCode;
      arr_ALL_Name_ID_For_Country.add(categoryResponse123);
      _listFilteredCountry.add(categoryResponse123);
      //children.add(new ListTile());
    }
  }

  void _onStateListSuccess(StateListEventResponseState responseState) {
    arr_ALL_Name_ID_For_State.clear();
    for (var i = 0; i < responseState.statelistresponse.details.length; i++) {
      print("CustomerCategoryResponse2 : " +
          responseState.statelistresponse.details[i].label);
      ALL_Name_ID categoryResponse123 = ALL_Name_ID();
      categoryResponse123.Name =
          responseState.statelistresponse.details[i].label;
      categoryResponse123.pkID =
          responseState.statelistresponse.details[i].value;
      arr_ALL_Name_ID_For_State.add(categoryResponse123);
      _listFilteredState.add(categoryResponse123);
      //children.add(new ListTile());
    }
  }

  void _onCityListSuccess(CityListEventResponseState responseState) {
    arr_ALL_Name_ID_For_District.clear();
    for (var i = 0; i < responseState.cityApiRespose.details.length; i++) {
      print("CustomerCategoryResponse2 : " +
          responseState.cityApiRespose.details[i].cityName);
      ALL_Name_ID categoryResponse123 = ALL_Name_ID();
      categoryResponse123.Name =
          responseState.cityApiRespose.details[i].cityName;
      categoryResponse123.pkID =
          responseState.cityApiRespose.details[i].cityCode;
      arr_ALL_Name_ID_For_District.add(categoryResponse123);
      _listFilteredCity.add(categoryResponse123);
      //children.add(new ListTile());
    }
  }

  Widget uploadImage(BuildContext context123) {
    //multiple_selectedImageFile.toSet().toList();

    return Column(
      children: [
        if (multiple_selectedImageFile.length != 0)
          Container(
            height: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Flexible(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.all(5),
                        height: 200,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                color: colorLightGray,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ImageFullScreenWrapperWidget(
                                  child: Image.file(
                                    File(
                                        multiple_selectedImageFile[index].path),
                                    height: 125,
                                    width: 125,
                                  ),
                                  dark: true,
                                ),
                              ),
                            ),
                            Align(
                                alignment: Alignment.topCenter,
                                child: Container(
                                  // padding: const EdgeInsets.only(left: 30,right: 30,top: 10,bottom: 10),
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    color: colorGray,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),

                                  child: GestureDetector(
                                    onTap: () {
                                      showCommonDialogWithTwoOptions(context,
                                          "Are you sure you want to delete this Image ?",
                                          negativeButtonTitle: "No",
                                          positiveButtonTitle: "Yes",
                                          onTapOfPositiveButton: () {
                                        Navigator.of(context).pop();
                                        multiple_selectedImageFile
                                            .removeAt(index);
                                        setState(() {});
                                      });
                                    },
                                    child: Icon(
                                      Icons.delete_forever,
                                      size: 32,
                                      color: colorPrimary,
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      );

                      // }
                    },
                    shrinkWrap: true,
                    itemCount: multiple_selectedImageFile.length,
                  ),
                ),
              ],
            ),
          )
        else
          Container(),
        getCommonButton(baseTheme, () async {
          if (await Permission.storage.isDenied) {
            //await Permission.storage.request();

            checkPhotoPermissionStatus();
          } else {
            pickMultipleImage(context, onMultipleImageSelection: (imageList) {
              setState(() {
                bool isTrueImageSized = false;
                for (int i = 0; i < imageList.length; i++) {
                  final bytes = imageList[i].readAsBytesSync().lengthInBytes;
                  final kb = bytes / 1024;
                  final mb = kb / 1024;

                  if (mb >= 4) {
                    showcustomdialogWithImageSized(
                        context1: context,
                        values: imageList,
                        lable: "Image Size Should not be Greater than 4 MB !");
                    //continue;
                    break;
                    /* showCommonDialogWithSingleOption(context,
                        "Image Size must be < 4mb Allowed to Upload Image !",
                        positiveButtonTitle: "OK");*/
                  }
                }

                for (int i = 0; i < imageList.length; i++) {
                  final bytes = imageList[i].readAsBytesSync().lengthInBytes;
                  final kb = bytes / 1024;
                  final mb = kb / 1024;

                  if (mb <= 4) {
                    multiple_selectedImageFile.add(imageList[i]);
                  }
                }

                //  multiple_selectedImageFile.addAll(imageList);
              });
            });
          }
        }, "Upload Image", backGroundColor: Colors.indigoAccent)
      ],
    );
  }

  Widget uploadVideosss(BuildContext context123) {
    //multiple_selectedImageFile.toSet().toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (MultipleVideoList.length != 0)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.all(5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            showCommonDialogWithTwoOptions(context,
                                "Are you sure you want to delete this Video ?",
                                negativeButtonTitle: "No",
                                positiveButtonTitle: "Yes",
                                onTapOfPositiveButton: () {
                              Navigator.of(context).pop();
                              MultipleVideoList.removeAt(index);
                              setState(() {});
                            });
                          },
                          child: Icon(
                            Icons.delete_forever,
                            size: 32,
                            color: colorPrimary,
                          ),
                        ),
                        Card(
                          elevation: 5,
                          color: colorLightGray,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: Container(
                            width: 300,
                            /* decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  color: colorLightGray,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),*/
                            child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    OpenFile.open(
                                        MultipleVideoList[index].path);
                                  },
                                  child: Text(
                                    MultipleVideoList[index]
                                        .path
                                        .split('/')
                                        .last,
                                    // overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 10, color: colorPrimary),
                                  ),
                                )),
                          ),
                        ),
                      ],
                    ),
                  );

                  // }
                },
                shrinkWrap: true,
                itemCount: MultipleVideoList.length,
              ),
            ],
          )
        else
          Container(),
        getCommonButton(baseTheme, () async {
          if (await Permission.storage.isDenied) {
            //await Permission.storage.request();

            checkPhotoPermissionStatus();
          } else {
            showModalBottomSheet(
                context: context,
                builder: (BuildContext bc) {
                  return SafeArea(
                    child: Container(
                      child: new Wrap(
                        children: <Widget>[
                          new ListTile(
                              leading: new Icon(Icons.photo_library),
                              title: new Text('Video Gallery'),
                              onTap: () async {
                                Navigator.of(context).pop();
                                _onImageButtonPressed(ImageSource.gallery,
                                    context: context);
                              }),
                          new ListTile(
                            leading: new Icon(Icons.photo_camera),
                            title: new Text('Camera'),
                            onTap: () async {
                              Navigator.of(context).pop();

                              _onImageButtonPressed(ImageSource.camera,
                                  context: context);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                });
          }
        }, "Upload Video", backGroundColor: Colors.indigoAccent)
      ],
    );
  }

  urlToFile(String imageUrl, String filenamee) async {
    if (Uri.parse(imageUrl).isAbsolute == true) {
      try {
        http.Response response = await http.get(Uri.parse(imageUrl));

        if (response.statusCode == 200) {
          Directory dir = await getApplicationDocumentsDirectory();
          dir.exists();
          String pathName = p.join(dir.path, filenamee);

          print("77575sdd7" + imageUrl);

          File file = new File(pathName);

          print("7757sds5sdd7" + file.path);

          try {
            await file.writeAsBytes(response.bodyBytes);
          } catch (e) {
            print("hdfhjfdhh" + e.toString());
          }

          multiple_selectedImageFile.add(file);
        }
      } catch (e) {
        print("775757" + e.toString());
      }

      setState(() {});
    }
  }

  urlVideoToFile(String imageUrl, String filenamee) async {
    if (Uri.parse(imageUrl).isAbsolute == true) {
      baseBloc.emit(ShowProgressIndicatorState(true));

      http.Response response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        Directory dir = await getApplicationDocumentsDirectory();
        dir.exists();
        String pathName = p.join(dir.path, filenamee);
        File file = new File(pathName);
        await file.writeAsBytes(response.bodyBytes);
        MultipleVideoList.add(file);
      }
      baseBloc.emit(ShowProgressIndicatorState(false));

      setState(() {});
    }
  }

  //urlVideoToFile

  Widget uploadVideo(BuildContext context123) {
    return Container(
      child: Column(
        children: <Widget>[
          videofile == null
              ? _isForUpdate //edit mode or not
                  ? Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: VideoURLFromListing.isNotEmpty
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.only(
                                      left: 5, right: 5, top: 5, bottom: 5),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    color: colorGray,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                  child: GestureDetector(
                                      onTap: () async {
                                        // If the video is playing, pause it.
                                        final String filePath = videofile.path;
                                        final Uri uri = Uri.file(filePath);

                                        /* if (!File(uri.toFilePath())
                                            .existsSync()) {
                                          throw '$uri does not exist!';
                                        }
                                        if (!await launch(uri.toString())) {
                                          throw 'Could not launch $uri';
                                        }*/

                                        // showVideoDialog(context, _controller);
                                      },
                                      child: Container()), //_previewVideo()),
                                ),
                                Align(
                                    alignment: Alignment.topCenter,
                                    child: Container(
                                      // padding: const EdgeInsets.only(left: 30,right: 30,top: 10,bottom: 10),
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        color: colorGray,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                      ),

                                      child: GestureDetector(
                                        onTap: () {
                                          showCommonDialogWithTwoOptions(
                                              context,
                                              "Are you sure you want to delete this Video ?",
                                              negativeButtonTitle: "No",
                                              positiveButtonTitle: "Yes",
                                              onTapOfPositiveButton: () {
                                            Navigator.of(context).pop();
                                            _controller.pause();
                                            videofile = null;
                                          });
                                        },
                                        child: Icon(
                                          Icons.delete_forever,
                                          size: 32,
                                          color: colorPrimary,
                                        ),
                                      ),
                                    )),
                              ],
                            )
                          : Container())
                  : Container()
              : Container(
                  margin: EdgeInsets.only(bottom: 20),
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                          onTap: () {
                            setState(() {
                              // If the video is playing, pause it.
                              /*if (_controller.value.isPlaying) {
                                _controller.pause();
                              } else {
                                // If the video is paused, play it.
                                _controller.play();
                              }*/

                              //showVideoDialog(context, _controller);
                            });
                          },
                          child: Container())), //_previewVideo())),
                ),
          getCommonButton(baseTheme, () {
            showModalBottomSheet(
                context: context,
                builder: (BuildContext bc) {
                  return SafeArea(
                    child: Container(
                      child: new Wrap(
                        children: <Widget>[
                          new ListTile(
                              leading: new Icon(Icons.photo_library),
                              title: new Text('Video Gallery'),
                              onTap: () async {
                                Navigator.of(context).pop();
                                _onImageButtonPressed(ImageSource.gallery,
                                    context: context);
                              }),
                          new ListTile(
                            leading: new Icon(Icons.photo_camera),
                            title: new Text('Camera'),
                            onTap: () async {
                              Navigator.of(context).pop();

                              _onImageButtonPressed(ImageSource.camera,
                                  context: context);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                });
          }, "Upload Video", backGroundColor: Colors.blueAccent)
        ],
      ),
    );
  }

  Future showVideoDialog(
    BuildContext context12345,
    VideoPlayerController videodialogcontroller,
  ) async {
    ThemeData baseTheme = Theme.of(context12345);
    await showDialog(
      context: context12345,
      builder: (context12345) {
        return VisibilityDetector(
            key: ObjectKey(flickManager),
            onVisibilityChanged: (visibility) {
              if (visibility.visibleFraction == 0 && this.mounted) {
                flickManager.flickControlManager?.autoPause();
              } else if (visibility.visibleFraction == 1) {
                flickManager.flickControlManager?.autoResume();
              }
            },
            child: Scaffold(
              body: Column(
                children: [
                  Container(
                    // height: 400,
                    child: FlickVideoPlayer(
                      flickManager: flickManager,
                      /* preferredDeviceOrientation: [
                  DeviceOrientation.landscapeRight,
                  DeviceOrientation.landscapeLeft
                ],*/
                      systemUIOverlay: [],
                      flickVideoWithControls: FlickVideoWithControls(
                          videoFit: BoxFit.contain,
                          controls: SafeArea(
                            child: FlickPortraitControls(),
                          ) //LandscapePlayerControls(),
                          ),
                      /* preferredDeviceOrientationFullscreen: [
                  DeviceOrientation.portraitUp,
                ],
                flickVideoWithControls: FlickVideoWithControls(
                  aspectRatioWhenLoading: _controller.value.aspectRatio,
                  controls: FlickPortraitControls(),

                  // closedCaptionTextStyle: TextStyle(fontSize: 8),
                ),
                flickVideoWithControlsFullscreen: FlickVideoWithControls(
                  aspectRatioWhenLoading: _controller.value.aspectRatio,
                  controls: FlickPortraitControls(),

                  // controls: CustomOrientationControls(dataManager: dataManager),
                ),*/
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    child: getCommonButton(baseTheme, () {
                      Navigator.pop(context12345);
                    }, "Close", backGroundColor: colorPrimary),
                  )
                ],
              ),
            ));

        /*return Center(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: colorWhite,
            ),
            width: double.maxFinite,
            child: Column(
              children: [
                Container(child: _previewVideoDialog()),
                Container(
                  margin:
                      EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Duration currentPosition = _controller.value.position;
                          Duration targetPosition =
                              currentPosition - const Duration(seconds: 10);
                          _controller.seekTo(targetPosition);
                        },
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (_controller.value.isPlaying) {
                            _controller.pause();
                          } else {
                            // If the video is paused, play it.
                            _controller.play();
                          }
                        },
                        child: Icon(
                          _controller.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Colors.black,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Duration currentPosition = _controller.value.position;
                          Duration targetPosition =
                              currentPosition + const Duration(seconds: 10);
                          _controller.seekTo(targetPosition);
                        },
                        child: Icon(
                          Icons.arrow_forward,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );*/
      },
    );
  }

  Widget _previewVideo() {
    final Text retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_controller == null) {
      return const Text(
        'You have not yet picked a video',
        textAlign: TextAlign.center,
      );
    }
    return Container(
      height: 300,
      width: 300,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: AspectRatioVideo(_controller),
      ),
    );
  }

  Widget _previewVideoDialog() {
    final Text retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_controller == null) {
      return const Text(
        'You have not yet picked a video',
        textAlign: TextAlign.center,
      );
    }
    return Container(
      height: 300,
      width: 300,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: AspectRatioVideo(_controller),
      ),
    );
  }

  Text _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }

  Future<void> _playVideo(XFile file) async {
    if (file != null && mounted) {
      await _disposeVideoController();
      VideoPlayerController controller;
      /* if (kIsWeb) {
        controller = VideoPlayerController.network(file.path);
      } else {*/
      controller = VideoPlayerController.file(File(file.path));
      //  }
      _controller = controller;
      // In web, most browsers won't honor a programmatic call to .play
      // if the video has a sound track (and is not muted).
      // Mute the video so it auto-plays in web!
      // This is not needed if the call to .play is the result of user
      // interaction (clicking on a "play" button, for example).
      const double volume = /*kIsWeb ? 0.0 :*/ 1.0;
      await _controller.setVolume(volume);
      await _controller.initialize();
      await _controller.setLooping(true);
      await _controller.play();
      await _controller.setLooping(true);

      flickManager = FlickManager(
        videoPlayerController: _controller,
      );

      setState(() {});
    }
  }

  Future<void> _disposeVideoController() async {
    if (_toBeDisposed != null) {
      await _toBeDisposed.dispose();
    }
    _toBeDisposed = _controller;
    _controller = null;
  }

  Future<void> _onImageButtonPressed(ImageSource source,
      {BuildContext context, bool isMultiImage = false}) async {
    bool ISDuplicate = false;

    XFile file = await picker.pickVideo(
        source: source, maxDuration: const Duration(seconds: 10));

    logger.i("Picke File : " + file.name);

    File file123 = File(file.path);

    final bytes = file123.readAsBytesSync().lengthInBytes;
    final kb = bytes / 1024;
    final mb = kb / 1024;

    videofile = file;

    if (mb >= 4) {
      showCommonDialogWithSingleOption(
          context, "Video Size Should not be Greater than 4 MB !",
          positiveButtonTitle: "OK");
    } else {
      videofile = file;

      if (MultipleVideoList.length != 0) {
        for (int i = 0; i < MultipleVideoList.length; i++) {
          logger.i("Array PAth : " + MultipleVideoList[i].path);

          if (file.path == MultipleVideoList[i].path) {
            ISDuplicate = true;
          } else {
            ISDuplicate = false;
          }
        }
      }

      if (ISDuplicate == true) {
        showCommonDialogWithSingleOption(context, "File Is Already Exist !",
            positiveButtonTitle: "OK");
      } else {
        MultipleVideoList.add(File(file.path));
      }

      //  dataList.add(VideoListData("Video ", file.path));

      //  await _playVideo(videofile);
    }

    setState(() {});
  }

  ///File Picker Demo
  /* Future<void> _onImageButtonPressed(ImageSource source,
      {BuildContext context, bool isMultiImage = false}) async {
    bool ISDuplicate = false;

    /* XFile file = await picker.pickVideo(
        source: source, maxDuration: const Duration(seconds: 10));*/

    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4', 'mkv', 'mpeg'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;

      print(file.name);
      print(file.bytes);
      print(file.size);
      print(file.extension);
      print(file.path);

      logger.i("Picke File : " + file.name);

      File file123 = File(file.path);

      final bytes = file123.readAsBytesSync().lengthInBytes;
      final kb = bytes / 1024;
      final mb = kb / 1024;

      //videofile = file;

      if (mb >= 4) {
        showCommonDialogWithSingleOption(
            context, "Video Size Should not be Greater than 4 MB !",
            positiveButtonTitle: "OK");
      } else {
        // videofile = file;

        if (MultipleVideoList.length != 0) {
          for (int i = 0; i < MultipleVideoList.length; i++) {
            logger.i("Array PAth : " + MultipleVideoList[i].path);

            if (file.path == MultipleVideoList[i].path) {
              ISDuplicate = true;
            } else {
              ISDuplicate = false;
            }
          }
        }

        if (ISDuplicate == true) {
          showCommonDialogWithSingleOption(context, "File Is Already Exist !",
              positiveButtonTitle: "OK");
        } else {
          MultipleVideoList.add(File(file.path));
        }

        //  dataList.add(VideoListData("Video ", file.path));

        //  await _playVideo(videofile);
      }
    } else {
      // User canceled the picker
    }

    /* String dir = (await getApplicationDocumentsDirectory()).path;
    String newPath = p.join(dir, '');
    File f = await File(file.path).copy(newPath);
    logger.i("Picke File ReName : " + f.path);*/

    setState(() {});
  }*/

  void checkPhotoPermissionStatus() async {
    bool granted = await Permission.storage.isGranted;
    bool Denied = await Permission.storage.isDenied;
    bool PermanentlyDenied = await Permission.storage.isPermanentlyDenied;

    print("PermissionStatus" +
        "Granted : " +
        granted.toString() +
        " Denied : " +
        Denied.toString() +
        " PermanentlyDenied : " +
        PermanentlyDenied.toString());

    if (Denied == true) {
      // openAppSettings();

      await Permission.storage.request();

/*      showCommonDialogWithSingleOption(
          context, "Location permission is required , You have to click on OK button to Allow the location access !",
          positiveButtonTitle: "OK",
      onTapOfPositiveButton: () async {
         await openAppSettings();
         Navigator.of(context).pop();

      }

      );*/

      // await Permission.location.request();
      // We didn't ask for permission yet or the permission has been denied before but not permanently.
    }

// You can can also directly ask the permission about its status.
    if (await Permission.location.isRestricted) {
      // The OS restricts access, for example because of parental controls.
      openAppSettings();
    }
    if (PermanentlyDenied == true) {
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enable it in the system settings.
      openAppSettings();
    }

    if (granted == true) {
      // The OS restricts access, for example because of parental controls.

      /*if (serviceLocation == true) {
        // Use location.
        _serviceEnabled=false;

         location.requestService();


      }
      else{
        _serviceEnabled=true;
        _getCurrentLocation();



      }*/
    }
  }

  void getVideoFromNetwork(String networkFile) async {
    await _disposeVideoController();
    VideoPlayerController controller;
    controller = VideoPlayerController.network(networkFile);

    //  }
    _controller = controller;
    // In web, most browsers won't honor a programmatic call to .play
    // if the video has a sound track (and is not muted).
    // Mute the video so it auto-plays in web!
    // This is not needed if the call to .play is the result of user
    // interaction (clicking on a "play" button, for example).
    const double volume = 1.0;

    ///*kIsWeb ? 0.0 :*/ 1.0;
    await _controller.setVolume(volume);
    await _controller.initialize();
    await _controller.setLooping(true);
    await _controller.play();

    flickManager = FlickManager(
      videoPlayerController: _controller,
    );
    setState(() {});
  }

  void getVideoFromNetwork1(String videoURLFromListing123) async {
    await getVideoFromNetwork(videoURLFromListing123);
  }

  showcustomdialogSignature({
    BuildContext context1,
  }) async {
    await showDialog(
      barrierDismissible: false,
      context: context1,
      builder: (BuildContext context123) {
        return SimpleDialog(
          title: Text("Signature"),
          children: [
            Container(
                width: MediaQuery.of(context123).size.width,
                child: Column(
                  children: [
                    SingleChildScrollView(
                        physics: ScrollPhysics(),
                        child: Column(children: <Widget>[])),
                  ],
                )),
          ],
        );
      },
    );
  }

  Widget _buildProductSearchView() {
    return InkWell(
      onTap: () {
        _onTapOfSearchProductView();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(left: 10, right: 10),
            child: Text("Search Product ",
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
            color: colorLightGray,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Container(
              height: 60,
              padding: EdgeInsets.only(left: 20, right: 20),
              width: double.maxFinite,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                        controller: _productNameController,
                        enabled: false,
                        decoration: InputDecoration(
                          hintText: "Tap to search product",
                          labelStyle: TextStyle(
                            color: Color(0xFF000000),
                          ),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF000000),
                        ) // baseTheme.textTheme.headline2.copyWith(color: colorBlack),

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
      ),
    );
  }

  Future<void> _onTapOfSearchProductView() async {
    /* navigateTo(context, SearchInquiryProductScreen.routeName).then((value) {
      if (value != null) {
        _searchDetails = value;
        _inquiryBloc.add(InquiryProductSearchNameCallEvent(InquiryProductSearchRequest(pkID: "",CompanyId: "10032",ListMode: "L",SearchKey: value)));
       print("ProductDetailss345"+_searchDetails.productName +"Alias"+ _searchDetails.productAlias);
      }
    });*/
    navigateTo(
      context,
      SearchInquiryProductScreen.routeName,
    ).then((value) {
      if (value != null) {
        _searchProductDetails = value;
        _productNameController.text =
            _searchProductDetails.productName.toString();
        _productIDController.text = _searchProductDetails.pkID.toString();
        //_totalAmountController.text = ""

      }
    });
  }

  void _OnComplaintImageUploadSucess(
      ComplaintUploadImageCallResponseState state) async {
    String Msg = _isForUpdate == true
        ? "Complaint Updated Successfully"
        : "Complaint Added Successfully";
    await showCommonDialogWithSingleOption(Globals.context, Msg,
        positiveButtonTitle: "OK", onTapOfPositiveButton: () {
      navigateTo(context, ComplaintPaginationListScreen.routeName,
          clearAllStack: true);
    });
  }

  void _onGetComplaintImageList(ComplaintEmpFollowerListResponseState state) {

    arr_ALL_Name_ID_For_AssignTo.clear();
    for (var i = 0; i < state.complaintEmpFollowerListResponse.details.length; i++) {
      ALL_Name_ID all_name_id = ALL_Name_ID();

      all_name_id.Name = state.complaintEmpFollowerListResponse.details[i].employeeName;
      all_name_id.pkID = state.complaintEmpFollowerListResponse.details[i].employeeID;

      arr_ALL_Name_ID_For_AssignTo.add(all_name_id);
    }
  }

  void getDetailsOfImage(String s, String d) async {
    await urlToFile(s, d.toString());
  }

  void getDetailsOfVideo(String s, String d) async {
    await urlVideoToFile(s, d.toString());
  }

  void _OnImageDeleteResponse(
      ComplaintNoToDeleteImageVideoResponseState state) {
    print("ImageSucessDelete" +
        " MSG : " +
        state.complaintNoToDeleteImageVideoResponse.details[0].column2);
  }

  showcustomdialogWithImageSized(
      {List<File> values, BuildContext context1, String lable}) async {
    // bool isVisible = false;
    List<File> Tvalues = [];
    for (int i = 0; i < values.length; i++) {
      final bytes = values[i].readAsBytesSync().lengthInBytes;
      final kb = bytes / 1024;
      final mb = kb / 1024;

      if (mb >= 4) {
        Tvalues.add(values[i]);
      }
    }

    await showDialog(
      barrierDismissible: false,
      context: context1,
      builder: (BuildContext context123) {
        return SimpleDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(32.0))),
          title: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: colorPrimary, //                   <--- border color
                ),
                borderRadius: BorderRadius.all(Radius.circular(
                        15.0) //                 <--- border radius here
                    ),
              ),
              child: Container(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    lable,
                    style: TextStyle(
                        color: colorPrimary, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ))),
          children: [
            SizedBox(
                width: MediaQuery.of(context123).size.width,
                child: Column(
                  children: [
                    SingleChildScrollView(
                        physics: ScrollPhysics(),
                        child: Column(children: <Widget>[
                          ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (ctx, index) {
                              return Container(
                                margin: EdgeInsets.only(
                                    left: 25, top: 10, bottom: 10, right: 10),
                                child: Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30))),
                                      child: ClipRRect(
                                        child: SizedBox.fromSize(
                                          child: Image.file(
                                            File(Tvalues[index].path),
                                            height: 100,
                                            width: 100,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    SizedBox(
                                      width: 150,
                                      child: Text(
                                        Tvalues[index].path.split('/').last,
                                        style: TextStyle(
                                            color: colorPrimary, fontSize: 12),
                                        softWrap: true,
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              /* return SimpleDialogOption(
                              onPressed: () => {
                                controller.text = values[index].Name,
                                controller2.text = values[index].Name1,
                              Navigator.of(context1).pop(),


                            },
                              child: Text(values[index].Name),
                            );*/
                            },
                            itemCount: Tvalues.length,
                          ),
                        ])),
                    getCommonButton(baseTheme, () {
                      Navigator.of(context1).pop();
                    }, "Close", width: 200)
                  ],
                )),
            /*Center(
            child: Container(
              padding: EdgeInsets.all(3.0),
              decoration: BoxDecoration(
                  color: Color(0xFFF27442),
                  borderRadius: BorderRadius.all(Radius.circular(
                      5.0) //                 <--- border radius here
                  ),
                  shape: BoxShape.rectangle,
                  border: Border.all(color: Color(0xFFF27442))),
              //color: Color(0xFFF27442),
              child: GestureDetector(
                child: Text(
                  "Close",
                  style: TextStyle(color: Color(0xFFFFFFFF)),
                ),
                onTap: () => Navigator.pop(context),
              ),
            ),
          ),*/
          ],
        );
      },
    );
  }

  showcustomdialogWithDuplicateImage(
      {List<File> values, BuildContext context1, String lable}) async {
    // bool isVisible = false;
    List<File> Tvalues = [];
    for (int i = 0; i < values.length; i++) {
      final bytes = values[i].readAsBytesSync().lengthInBytes;
      final kb = bytes / 1024;
      final mb = kb / 1024;

      if (mb >= 4) {
        Tvalues.add(values[i]);
      }
    }

    await showDialog(
      barrierDismissible: false,
      context: context1,
      builder: (BuildContext context123) {
        return SimpleDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(32.0))),
          title: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: colorPrimary, //                   <--- border color
                ),
                borderRadius: BorderRadius.all(Radius.circular(
                        15.0) //                 <--- border radius here
                    ),
              ),
              child: Container(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    lable,
                    style: TextStyle(
                        color: colorPrimary, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ))),
          children: [
            SizedBox(
                width: MediaQuery.of(context123).size.width,
                child: Column(
                  children: [
                    SingleChildScrollView(
                        physics: ScrollPhysics(),
                        child: Column(children: <Widget>[
                          ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (ctx, index) {
                              return Container(
                                margin: EdgeInsets.only(
                                    left: 25, top: 10, bottom: 10, right: 10),
                                child: Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30))),
                                      child: ClipRRect(
                                        child: SizedBox.fromSize(
                                          child: Image.file(
                                            File(Tvalues[index].path),
                                            height: 100,
                                            width: 100,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    SizedBox(
                                      width: 150,
                                      child: Text(
                                        Tvalues[index].path.split('/').last,
                                        style: TextStyle(
                                            color: colorPrimary, fontSize: 12),
                                        softWrap: true,
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              /* return SimpleDialogOption(
                              onPressed: () => {
                                controller.text = values[index].Name,
                                controller2.text = values[index].Name1,
                              Navigator.of(context1).pop(),


                            },
                              child: Text(values[index].Name),
                            );*/
                            },
                            itemCount: Tvalues.length,
                          ),
                        ])),
                    getCommonButton(baseTheme, () {
                      Navigator.of(context1).pop();
                    }, "Close", width: 200)
                  ],
                )),
            /*Center(
            child: Container(
              padding: EdgeInsets.all(3.0),
              decoration: BoxDecoration(
                  color: Color(0xFFF27442),
                  borderRadius: BorderRadius.all(Radius.circular(
                      5.0) //                 <--- border radius here
                  ),
                  shape: BoxShape.rectangle,
                  border: Border.all(color: Color(0xFFF27442))),
              //color: Color(0xFFF27442),
              child: GestureDetector(
                child: Text(
                  "Close",
                  style: TextStyle(color: Color(0xFFFFFFFF)),
                ),
                onTap: () => Navigator.pop(context),
              ),
            ),
          ),*/
          ],
        );
      },
    );
  }
}

/// Random Number withFile Create
/*
urlVideoToFile(String imageUrl, String filenamee) async {
// generate random number.
  var rng = new Random();
// get temporary directory of device.
  // Directory tempDir = await getTemporaryDirectory();
  //tempDir.deleteSync(recursive: true);
  Directory dir = await getApplicationDocumentsDirectory();
  dir.exists();
  String pathName = p.join(dir.path, filenamee);
// get temporary path from temporary directory.
  // String tempPath = tempDir.path;
// create a new file in temporary path with random file name.
  File file = new File(pathName); //(rng.nextInt(100)).toString() + '.png');
// call http.get method and pass imageUrl into it to get response.
  http.Response response = await http.get(Uri.parse(imageUrl));
// write bodyBytes received in response to file.
  await file.writeAsBytes(response.bodyBytes);
// now return the file which is created with random name in
// temporary directory and image bytes from response is written to // that file.
  MultipleVideoList.add(file);
  // multiple_selectedImageFile.add(file);
  // return file;
}
*/
