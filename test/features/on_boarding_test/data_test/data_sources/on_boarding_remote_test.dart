import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xplor/const/local_storage/pref_const_key.dart';
import 'package:xplor/features/on_boarding/data/data_sources/on_boarding_remote.dart';
import 'package:xplor/features/on_boarding/domain/entities/ob_boarding_verify_otp_entity.dart';
import 'package:xplor/features/on_boarding/domain/entities/on_boarding_send_otp_entity.dart';

import '../../helpers/test_helper.mocks.dart';

void main() {
  group('OnBoardingApiService', () {
    late OnBoardingApiServiceImpl apiService;
    late MockDio mockDio;
    late MockSharedPreferencesHelper prefHelper;
    SharedPreferences pref;

    setUp(() async {
      mockDio = MockDio();
      SharedPreferences.setMockInitialValues({}); //set values here
      pref = await SharedPreferences.getInstance();
      pref.setString(
        PrefConstKeys.token,
        "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ1c2VyXzE0NmMzNTJjLTNiMzEtNGNjYS04OWYwLTJlYjM4YWU4NGRiMCIsImlhdCI6MTcxMjU3OTM4OSwiZXhwIjoxNzE2MTc5Mzg5fQ.tT_Rx8f1eUiFSrXX6DNsUH9FiGrhGzl8m5Z7YD3i6ug",
      );
      pref.setString(
          PrefConstKeys.userId, "user_146c352c-3b31-4cca-89f0-2eb38ae84db0");
      pref.getString(PrefConstKeys.kycVerified);
      pref.getString(PrefConstKeys.roleAssigned);
      prefHelper = MockSharedPreferencesHelper();
      apiService = OnBoardingApiServiceImpl(
          dio: mockDio, preferencesHelper: prefHelper, helper: pref);
    });

    group('sendOtpOnBoarding', () {
      test('should return the otp when the call to the API is successful',
          () async {
        final entity = OnBoardingSendOtpEntity(phoneNumber: '+918234567890');
        final responseData = {
          'data': {'key': '123456'}
        };
        when(mockDio.post(any,
                data: anyNamed('data'), options: anyNamed('options')))
            .thenAnswer((_) async => Response(
                data: responseData,
                statusCode: 200,
                requestOptions: RequestOptions(
                  contentType: Headers.jsonContentType,
                )));

        final result = await apiService.sendOtpOnBoarding(entity);

        expect(result, '123456');
        verify(mockDio.post(any,
                data: anyNamed('data'), options: anyNamed('options')))
            .called(1);
      });

      test('should throw an exception when the call to the API fails', () {
        final entity = OnBoardingSendOtpEntity();
        when(mockDio.post(any,
                data: anyNamed('data'), options: anyNamed('options')))
            .thenThrow(Exception('Failed to send OTP'));

        expect(() => apiService.sendOtpOnBoarding(entity), throwsException);
        verify(mockDio.post(any,
                data: anyNamed('data'), options: anyNamed('options')))
            .called(1);
      });
    });

    group('verifyOtpOnBoarding', () {
      // test('should call the API to verify OTP', () async {
      //   final entity = OnBoardingVerifyOtpEntity(key: 'key', otp: '123456');
      //   final responseData = {
      //     "success": true,
      //     "message": "OK",
      //     "data": {
      //       "token":
      //           "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ1c2VyXzE0NmMzNTJjLTNiMzEtNGNjYS04OWYwLTJlYjM4YWU4NGRiMCIsImlhdCI6MTcxMjU3OTM4OSwiZXhwIjoxNzE2MTc5Mzg5fQ.tT_Rx8f1eUiFSrXX6DNsUH9FiGrhGzl8m5Z7YD3i6ug",
      //       "userId": "user_146c352c-3b31-4cca-89f0-2eb38ae84db0"
      //     }
      //   };
      //
      //   when(mockDio.post(
      //     any,
      //     data: anyNamed('data'),
      //   )).thenAnswer((_) async => Response(
      //       data: responseData,
      //       statusCode: 200,
      //       requestOptions: RequestOptions(
      //         contentType: Headers.jsonContentType,
      //       )));
      //
      //   final res = await apiService.verifyOtpOnBoarding(entity);
      //
      //   expect(() => res, isA<void>());
      //
      //   verify(mockDio.post(any,
      //           data: entity.toJson(), options: anyNamed('options')))
      //       .called(1);
      // });

      test('should throw an exception when the call to the API fails', () {
        final entity = OnBoardingVerifyOtpEntity();
        when(mockDio.post(any,
                data: anyNamed('data'), options: anyNamed('options')))
            .thenThrow(Exception('Failed to verify OTP'));

        expect(() => apiService.verifyOtpOnBoarding(entity), throwsException);
        verify(mockDio.post(any,
                data: anyNamed('data'), options: anyNamed('options')))
            .called(1);
      });
    });

    group('getUserJourney', () {
      test('should call the API to get user journey', () async {
        final responseData = {
          "data": {"kycVerified": false, "personaCreated": false}
        };
        when(mockDio.get(any, options: anyNamed('options')))
            .thenAnswer((_) async => Response(
                data: responseData,
                statusCode: 200,
                requestOptions: RequestOptions(
                  contentType: Headers.jsonContentType,
                )));

        await apiService.getUserJourney();

        verify(mockDio.get(any, options: anyNamed('options'))).called(1);
      });

      test('should throw an exception when the call to the API fails', () {
        when(mockDio.get(any, options: anyNamed('options')))
            .thenThrow(Exception('Failed to get user journey'));

        expect(() => apiService.getUserJourney(), throwsException);
        verify(mockDio.get(any, options: anyNamed('options'))).called(1);
      });
    });

    // group('assignRoleOnBoarding', () {
    //   test('should return true when role assignment is successful', () async {
    //     final entity = OnBoardingAssignRoleEntity(
    //         roleId: 'role_61b32a02-d422-4b10-b060-945e0e2e6418');
    //     final responseData = {
    //       "_id": "user_146c352c-3b31-4cca-89f0-2eb38ae84db0",
    //       "phoneNumber": "+919876546788",
    //       "verified": true,
    //       "kycStatus": false,
    //       "wallet": null,
    //       "updated_at": "2024-04-08T12:21:19.308Z",
    //       "created_at": "2024-04-08T12:21:19.308Z",
    //       "__v": 0,
    //       "role": {
    //         "_id": "role_61b32a02-d422-4b10-b060-945e0e2e6418",
    //         "type": "AGENT",
    //         "updated_at": "2024-04-05T13:16:27.007Z",
    //         "created_at": "2024-04-05T13:16:27.007Z",
    //         "__v": 0
    //       }
    //     };
    //     when(mockDio.patch(any,
    //             data: entity.toJson(), options: anyNamed('options')))
    //         .thenAnswer((_) async => Response(
    //             data: responseData,
    //             statusCode: 200,
    //             requestOptions: RequestOptions(
    //               contentType: Headers.jsonContentType,
    //             )));
    //
    //     final result = await apiService.assignRoleOnBoarding(entity);
    //
    //     expect(result, true);
    //     verify(mockDio.patch(any,
    //             data: entity.toJson(), options: anyNamed('options')))
    //         .called(1);
    //   });
    //
    // test('should throw an exception when the call to the API fails', () async {
    //   final entity = OnBoardingAssignRoleEntity(
    //       roleId: 'role_61b32a02-d422-4b10-b060-945e0e2e6418');
    //   when(mockDio.patch(any,
    //           data: anyNamed('data'), options: anyNamed('options')))
    //       .thenAnswer(
    //     (_) async => Response(
    //         data: Exception('Unexpected error occurred'),
    //         statusCode: 500,
    //         requestOptions: RequestOptions(
    //           contentType: Headers.jsonContentType,
    //         )),
    //   );
    //
    //   final result = await apiService.assignRoleOnBoarding(entity);
    //
    //   expect(result, Exception('Unexpected error occurred'));
    //   verify(mockDio.patch(any,
    //           data: anyNamed('data'), options: anyNamed('options')))
    //       .called(1);
    // });
    // });

    group('getUserRolesOnBoarding', () {
      test(
          'should return a list of user roles when the call to the API is successful',
          () async {
        final responseData = {
          'data': [
            {'id': 1, 'name': 'Admin'},
            {'id': 2, 'name': 'User'}
          ]
        };
        when(mockDio.get(any, options: anyNamed('options')))
            .thenAnswer((_) async => Response(
                data: responseData,
                statusCode: 200,
                requestOptions: RequestOptions(
                  contentType: Headers.jsonContentType,
                )));

        final result = await apiService.getUserRolesOnBoarding();

        expect(result.length, 2);
        verify(mockDio.get(any, options: anyNamed('options'))).called(1);
      });

      test('should throw an exception when the call to the API fails', () {
        when(mockDio.get(any, options: anyNamed('options')))
            .thenThrow(Exception('Failed to get user roles'));

        expect(() => apiService.getUserRolesOnBoarding(), throwsException);
        verify(mockDio.get(any, options: anyNamed('options'))).called(1);
      });
    });

    group('updateUserKycOnBoarding', () {
      test('should return true when KYC update is successful', () async {
        final responseData = {
          "success": true,
          "message": "OK",
          "data": {
            "_id": "user_146c352c-3b31-4cca-89f0-2eb38ae84db0",
            "phoneNumber": "+919876546788",
            "verified": true,
            "kycStatus": true,
            "wallet": null,
            "updated_at": "2024-04-08T12:21:19.308Z",
            "created_at": "2024-04-08T12:21:19.308Z",
            "__v": 0,
            "role": "role_61b32a02-d422-4b10-b060-945e0e2e6418",
            "kyc": {
              "lastName": "Doe",
              "firstName": "John",
              "address": "123 Main St",
              "email": "john.doe@example.com",
              "gender": "Male",
              "provider": {"id": "provider123", "name": "Provider Name"},
              "_id": "kyc_ee7815ac-4c9c-4a8a-97df-5305a979d346",
              "updated_at": "2024-04-08T12:40:23.490Z",
              "created_at": "2024-04-08T12:40:23.490Z"
            }
          }
        };
        when(mockDio.patch(any, options: anyNamed('options')))
            .thenAnswer((_) async => Response(
                data: responseData,
                statusCode: 200,
                requestOptions: RequestOptions(
                  contentType: Headers.jsonContentType,
                  headers: {'Authorization': 'token'},
                )));

        final result = await apiService.updateUserKycOnBoarding();

        expect(result, true);
        verify(mockDio.patch(any, options: anyNamed('options'))).called(1);
      });

      test('should return false when KYC update fails', () async {
        when(mockDio.patch(any, options: anyNamed('options')))
            .thenThrow(Exception('Failed to update KYC'));

        final result = await apiService.updateUserKycOnBoarding();

        expect(result, false);
        //verify(mockDio.patch(any, options: anyNamed('options'))).called(1);
      });
    });
  });
}
