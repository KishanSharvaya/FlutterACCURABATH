import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soleoserp/blocs/base/base_bloc.dart';
import 'package:soleoserp/models/api_requests/city_list_request.dart';
import 'package:soleoserp/models/api_requests/complaint/complaint_delete_request.dart';
import 'package:soleoserp/models/api_requests/complaint/complaint_emp_follower_list_request.dart';
import 'package:soleoserp/models/api_requests/complaint/complaint_image_delete_request.dart';
import 'package:soleoserp/models/api_requests/complaint/complaint_list_request.dart';
import 'package:soleoserp/models/api_requests/complaint/complaint_no_to_delete_img_video_request.dart';
import 'package:soleoserp/models/api_requests/complaint/complaint_save_request.dart';
import 'package:soleoserp/models/api_requests/complaint/complaint_search_by_Id_request.dart';
import 'package:soleoserp/models/api_requests/complaint/complaint_search_request.dart';
import 'package:soleoserp/models/api_requests/complaint/complaint_upload_image_request.dart';
import 'package:soleoserp/models/api_requests/complaint/fetch_image_list.dart';
import 'package:soleoserp/models/api_requests/country_list_request.dart';
import 'package:soleoserp/models/api_requests/customer_label_value_request.dart';
import 'package:soleoserp/models/api_requests/customer_source_list_request.dart';
import 'package:soleoserp/models/api_requests/state_list_request.dart';
import 'package:soleoserp/models/api_requests/transection_mode_list_request.dart';
import 'package:soleoserp/models/api_responses/city_api_response.dart';
import 'package:soleoserp/models/api_responses/complaint/complaint_emp_follower_list_response.dart';
import 'package:soleoserp/models/api_responses/complaint/complaint_image_delete_response.dart';
import 'package:soleoserp/models/api_responses/complaint/complaint_list_response.dart';
import 'package:soleoserp/models/api_responses/complaint/complaint_no_to_delete_img_video_response.dart';
import 'package:soleoserp/models/api_responses/complaint/complaint_upload_image_response.dart';
import 'package:soleoserp/models/api_responses/complaint/fetch_complaint_image_list_response.dart';
import 'package:soleoserp/models/api_responses/complaint_delete_response.dart';
import 'package:soleoserp/models/api_responses/complaint_save_response.dart';
import 'package:soleoserp/models/api_responses/complaint_search_response.dart';
import 'package:soleoserp/models/api_responses/country_list_response.dart';
import 'package:soleoserp/models/api_responses/customer_label_value_response.dart';
import 'package:soleoserp/models/api_responses/customer_source_response.dart';
import 'package:soleoserp/models/api_responses/state_list_response.dart';
import 'package:soleoserp/repositories/repository.dart';

part 'complaint_event.dart';
part 'complaint_state.dart';

class ComplaintScreenBloc
    extends Bloc<ComplaintScreenEvents, ComplaintScreenStates> {
  Repository userRepository = Repository.getInstance();
  BaseBloc baseBloc;

  ComplaintScreenBloc(this.baseBloc) : super(ComplaintScreenInitialState());

  @override
  Stream<ComplaintScreenStates> mapEventToState(
      ComplaintScreenEvents event) async* {
    if (event is ComplaintListCallEvent) {
      yield* _mapComplaintListCallEventToState(event);
    }
    if (event is ComplaintSearchByNameCallEvent) {
      yield* _mapSearchByNameCallEventToState(event);
    }
    if (event is ComplaintSearchByIDCallEvent) {
      yield* _mapSearchByIDCallEventToState(event);
    }
    if (event is ComplaintDeleteCallEvent) {
      yield* _mapDeleteCallEventToState(event);
    }

    if (event is SearchFollowupCustomerListByNameCallEvent) {
      yield* _mapFollowupCustomerListByNameCallEventToState(event);
    }
    if (event is CustomerSourceCallEvent) {
      yield* _mapCustomerSourceCallEventToState(event);
    }
    if (event is ComplaintSaveCallEvent) {
      yield* _mapSaveCallEventToState(event);
    }
    if (event is CountryCallEvent) {
      yield* _mapCountryListCallEventToState(event);
    }
    if (event is StateCallEvent) {
      yield* _mapStateListCallEventToState(event);
    }
    if (event is CityCallEvent) {
      yield* _mapCityListCallEventToState(event);
    }

    if (event is ComplaintUploadImageNameCallEvent) {
      yield* _mapComplaintUploadImageCallEventToState(event);
    }

    if (event is FetchComplaintImageListRequestEvent) {
      yield* _mapFetchComplaintImageListCallEventToState(event);
    }
    if (event is ComplaintImageDeleteRequestCallEvent) {
      yield* _mapComplaintDeleteImageCallEventToState(event);
    }

    if (event is ComplaintNoToDeleteImageVideoRequestEvent) {
      yield* _MapComplaintNoToDeleteImageVideo(event);
    }

    if (event is ComplaintEmpFollowerListRequestEvent) {
      yield* _mapComplaintEmpFollowerListEventState(event);
    }
  }

  Stream<ComplaintScreenStates> _mapComplaintListCallEventToState(
      ComplaintListCallEvent event) async* {
    try {
      baseBloc.emit(ShowProgressIndicatorState(true));

      ComplaintListResponse response = await userRepository.getComplaintList(
          event.pageNo, event.complaintListRequest);
      yield ComplaintListResponseState(event.pageNo, response);
    } catch (error, stacktrace) {
      baseBloc.emit(ApiCallFailureState(error));
      print(stacktrace);
    } finally {
      await Future.delayed(const Duration(milliseconds: 500), () {});
      baseBloc.emit(ShowProgressIndicatorState(false));
    }
  }

  Stream<ComplaintScreenStates> _mapSearchByNameCallEventToState(
      ComplaintSearchByNameCallEvent event) async* {
    try {
      baseBloc.emit(ShowProgressIndicatorState(true));

      ComplaintSearchResponse response = await userRepository
          .getComplaintSearchByName(event.complaintSearchRequest);
      yield ComplaintSearchByNameResponseState(response);
    } catch (error, stacktrace) {
      baseBloc.emit(ApiCallFailureState(error));
      print(stacktrace);
    } finally {
      await Future.delayed(const Duration(milliseconds: 500), () {});
      baseBloc.emit(ShowProgressIndicatorState(false));
    }
  }

  Stream<ComplaintScreenStates> _mapSearchByIDCallEventToState(
      ComplaintSearchByIDCallEvent event) async* {
    try {
      baseBloc.emit(ShowProgressIndicatorState(true));

      ComplaintListResponse response = await userRepository
          .getComplaintSearchByID(event.pkID, event.complaintSearchByIDRequest);
      yield ComplaintSearchByIDResponseState(response);
    } catch (error, stacktrace) {
      baseBloc.emit(ApiCallFailureState(error));
      print(stacktrace);
    } finally {
      await Future.delayed(const Duration(milliseconds: 500), () {});
      baseBloc.emit(ShowProgressIndicatorState(false));
    }
  }

  Stream<ComplaintScreenStates> _mapDeleteCallEventToState(
      ComplaintDeleteCallEvent event) async* {
    try {
      baseBloc.emit(ShowProgressIndicatorState(true));

      ComplaintDeleteResponse response =
          await userRepository.DeleteComplaintBypkID(
              event.pkID, event.complaintDeleteRequest);
      yield ComplaintDeleteResponseState(response);
    } catch (error, stacktrace) {
      baseBloc.emit(ApiCallFailureState(error));
      print(stacktrace);
    } finally {
      await Future.delayed(const Duration(milliseconds: 500), () {});
      baseBloc.emit(ShowProgressIndicatorState(false));
    }
  }

  Stream<ComplaintScreenStates> _mapFollowupCustomerListByNameCallEventToState(
      SearchFollowupCustomerListByNameCallEvent event) async* {
    try {
      baseBloc.emit(ShowProgressIndicatorState(true));
      CustomerLabelvalueRsponse response =
          await userRepository.getCustomerListSearchByName(event.request);
      yield FollowupCustomerListByNameCallResponseState(response);
    } catch (error, stacktrace) {
      baseBloc.emit(ApiCallFailureState(error));
      print(stacktrace);
    } finally {
      await Future.delayed(const Duration(milliseconds: 500), () {});

      baseBloc.emit(ShowProgressIndicatorState(false));
    }
  }

  Stream<ComplaintScreenStates> _mapCustomerSourceCallEventToState(
      CustomerSourceCallEvent event) async* {
    try {
      baseBloc.emit(ShowProgressIndicatorState(true));

      CustomerSourceResponse respo =
          await userRepository.customer_Source_List_call(event.request1);
      yield CustomerSourceCallEventResponseState(respo);
    } catch (error, stacktrace) {
      baseBloc.emit(ApiCallFailureState(error));
      print(stacktrace);
    } finally {
      baseBloc.emit(ShowProgressIndicatorState(false));
    }
  }

  Stream<ComplaintScreenStates> _mapSaveCallEventToState(
      ComplaintSaveCallEvent event) async* {
    try {
      baseBloc.emit(ShowProgressIndicatorState(true));

      ComplaintSaveResponse response = await userRepository.getComplaintSave(
          event.pkID, event.complaintSaveRequest);
      yield ComplaintSaveResponseState(response);
    } catch (error, stacktrace) {
      baseBloc.emit(ApiCallFailureState(error));
      print(stacktrace);
    } finally {
      await Future.delayed(const Duration(milliseconds: 500), () {});
      baseBloc.emit(ShowProgressIndicatorState(false));
    }
  }

  Stream<ComplaintScreenStates> _mapCountryListCallEventToState(
      CountryCallEvent event) async* {
    try {
      baseBloc.emit(ShowProgressIndicatorState(true));
      CountryListResponse respo =
          await userRepository.country_list_call(event.countryListRequest);
      yield CountryListEventResponseState(respo);
    } catch (error, stacktrace) {
      baseBloc.emit(ApiCallFailureState(error));
      print(stacktrace);
    } finally {
      baseBloc.emit(ShowProgressIndicatorState(false));
    }
  }

  Stream<ComplaintScreenStates> _mapStateListCallEventToState(
      StateCallEvent event) async* {
    try {
      baseBloc.emit(ShowProgressIndicatorState(true));

      StateListResponse respo =
          await userRepository.state_list_call(event.stateListRequest);
      yield StateListEventResponseState(respo);
    } catch (error, stacktrace) {
      baseBloc.emit(ApiCallFailureState(error));
      print(stacktrace);
    } finally {
      baseBloc.emit(ShowProgressIndicatorState(false));
    }
  }

  Stream<ComplaintScreenStates> _mapCityListCallEventToState(
      CityCallEvent event) async* {
    try {
      baseBloc.emit(ShowProgressIndicatorState(true));

      CityApiRespose respo =
          await userRepository.city_list_details(event.cityApiRequest);
      yield CityListEventResponseState(respo);
    } catch (error, stacktrace) {
      baseBloc.emit(ApiCallFailureState(error));
      print(stacktrace);
    } finally {
      baseBloc.emit(ShowProgressIndicatorState(false));
    }
  }

  Stream<ComplaintScreenStates> _mapComplaintUploadImageCallEventToState(
      ComplaintUploadImageNameCallEvent event) async* {
    try {
      baseBloc.emit(ShowProgressIndicatorState(true));
      ComplaintImageUploadResponse response;
      for (int i = 0; i < event.expenseImageFile.length; i++) {
        if (event.expenseImageFile[i].path != "") {
          event.complaintUploadImageAPIRequest.DocName =
              event.expenseImageFile[i].path.split('/').last;
          event.complaintUploadImageAPIRequest.file = event.expenseImageFile[i];
          response = await userRepository.getComplaintuploadImage(
              event.expenseImageFile[i], event.complaintUploadImageAPIRequest);
        }
      }

      // print("RESPPDDDD" +  await userRepository.getuploadImage(event.expenseUploadImageAPIRequest).toString());
      yield ComplaintUploadImageCallResponseState(response);
    } catch (error, stacktrace) {
      baseBloc.emit(ApiCallFailureState(error));
      print(stacktrace);
    } finally {
      baseBloc.emit(ShowProgressIndicatorState(false));
    }
  }

  Stream<ComplaintScreenStates> _mapFetchComplaintImageListCallEventToState(
      FetchComplaintImageListRequestEvent event) async* {
    try {
      baseBloc.emit(ShowProgressIndicatorState(true));

      FetchComplaintImageListResponse respo =
          await userRepository.ComplaintImage_list_details(
              event.fetchComplaintImageListRequest);
      yield FetchComplaintImageListResponseState(respo, event.complaintDetails);
    } catch (error, stacktrace) {
      baseBloc.emit(ApiCallFailureState(error));
      print(stacktrace);
    } finally {
      baseBloc.emit(ShowProgressIndicatorState(false));
    }
  }

  Stream<ComplaintScreenStates> _mapComplaintDeleteImageCallEventToState(
      ComplaintImageDeleteRequestCallEvent event) async* {
    try {
      baseBloc.emit(ShowProgressIndicatorState(true));
      ComplaintImageDeleteResponse response;
      for (int i = 0; i < event._arrrImageVideoList123.length; i++) {
        response = await userRepository.getComplaintImageDeleteApi(
            event._arrrImageVideoList123[i].pkID,
            event.complaintImageDeleteRequest);
      }

      // print("RESPPDDDD" +  await userRepository.getuploadImage(event.expenseUploadImageAPIRequest).toString());
      yield ComplaintImageDeleteResponseCallResponseState(response);
    } catch (error, stacktrace) {
      baseBloc.emit(ApiCallFailureState(error));
      print(stacktrace);
    } finally {
      baseBloc.emit(ShowProgressIndicatorState(false));
    }
  }

  Stream<ComplaintScreenStates> _MapComplaintNoToDeleteImageVideo(
      ComplaintNoToDeleteImageVideoRequestEvent event) async* {
    try {
      baseBloc.emit(ShowProgressIndicatorState(true));

      ComplaintNoToDeleteImageVideoResponse respo =
          await userRepository.getComplaintNoToDeleteImageVideoAPI(
              event.ComplaintNo, event.complaintNoToDeleteImageVideoRequest);
      yield ComplaintNoToDeleteImageVideoResponseState(respo);
    } catch (error, stacktrace) {
      baseBloc.emit(ApiCallFailureState(error));
      print(stacktrace);
    } finally {
      baseBloc.emit(ShowProgressIndicatorState(false));
    }
  }

  Stream<ComplaintScreenStates> _mapComplaintEmpFollowerListEventState(
      ComplaintEmpFollowerListRequestEvent event) async* {
    try {
      baseBloc.emit(ShowProgressIndicatorState(true));

      ComplaintEmpFollowerListResponse respo =
          await userRepository.getComplaintEmployeeFollowerAPI(
              event.complaintEmpFollowerListRequest);
      yield ComplaintEmpFollowerListResponseState(respo);
    } catch (error, stacktrace) {
      baseBloc.emit(ApiCallFailureState(error));
      print(stacktrace);
    } finally {
      baseBloc.emit(ShowProgressIndicatorState(false));
    }
  }
}
