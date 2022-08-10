part of 'complaint_bloc.dart';

abstract class ComplaintScreenStates extends BaseStates {
  const ComplaintScreenStates();
}

///all states of AuthenticationStates

class ComplaintScreenInitialState extends ComplaintScreenStates {}

class ComplaintListResponseState extends ComplaintScreenStates {
  final ComplaintListResponse complaintListResponse;
  final int newPage;

  ComplaintListResponseState(this.newPage, this.complaintListResponse);
}

class ComplaintSearchByNameResponseState extends ComplaintScreenStates {
  final ComplaintSearchResponse complaintSearchResponse;

  ComplaintSearchByNameResponseState(this.complaintSearchResponse);
}

class ComplaintSearchByIDResponseState extends ComplaintScreenStates {
  final ComplaintListResponse complaintSearchByIDResponse;

  ComplaintSearchByIDResponseState(this.complaintSearchByIDResponse);
}

class ComplaintDeleteResponseState extends ComplaintScreenStates {
  final ComplaintDeleteResponse complaintDeleteResponse;

  ComplaintDeleteResponseState(this.complaintDeleteResponse);
}

class FollowupCustomerListByNameCallResponseState
    extends ComplaintScreenStates {
  final CustomerLabelvalueRsponse response;

  FollowupCustomerListByNameCallResponseState(this.response);
}

class CustomerSourceCallEventResponseState extends ComplaintScreenStates {
  final CustomerSourceResponse sourceResponse;
  CustomerSourceCallEventResponseState(this.sourceResponse);
}

class ComplaintSaveResponseState extends ComplaintScreenStates {
  final ComplaintSaveResponse complaintSaveResponse;

  ComplaintSaveResponseState(this.complaintSaveResponse);
}

class CountryListEventResponseState extends ComplaintScreenStates {
  final CountryListResponse countrylistresponse;
  CountryListEventResponseState(this.countrylistresponse);
}

class StateListEventResponseState extends ComplaintScreenStates {
  final StateListResponse statelistresponse;
  StateListEventResponseState(this.statelistresponse);
}

class CityListEventResponseState extends ComplaintScreenStates {
  final CityApiRespose cityApiRespose;
  CityListEventResponseState(this.cityApiRespose);
}

class ComplaintUploadImageCallResponseState extends ComplaintScreenStates {
  final ComplaintImageUploadResponse complaintImageUploadResponse;

  ComplaintUploadImageCallResponseState(this.complaintImageUploadResponse);
}

class FetchComplaintImageListResponseState extends ComplaintScreenStates {
  final ComplaintDetails complaintDetails;
  final FetchComplaintImageListResponse fetchComplaintImageListResponse;
  FetchComplaintImageListResponseState(
      this.fetchComplaintImageListResponse, this.complaintDetails);
}


class ComplaintImageDeleteResponseCallResponseState
    extends ComplaintScreenStates {
  final ComplaintImageDeleteResponse complaintImageDeleteResponse;

  ComplaintImageDeleteResponseCallResponseState(
      this.complaintImageDeleteResponse);
}

class ComplaintNoToDeleteImageVideoResponseState extends ComplaintScreenStates {
  final ComplaintNoToDeleteImageVideoResponse complaintNoToDeleteImageVideoResponse;

  ComplaintNoToDeleteImageVideoResponseState(this.complaintNoToDeleteImageVideoResponse);
}

class ComplaintEmpFollowerListResponseState extends ComplaintScreenStates {
  final ComplaintEmpFollowerListResponse complaintEmpFollowerListResponse;

  ComplaintEmpFollowerListResponseState(this.complaintEmpFollowerListResponse);
}