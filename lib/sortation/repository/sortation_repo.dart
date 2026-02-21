import 'package:get/get.dart';
import 'package:opsapp/utils/client_api.dart';
import 'package:opsapp/utils/app_constants.dart';

class SortationRepo {
  final ApiClient apiClient;

  SortationRepo({required this.apiClient});

  Future<Response> getContainers(int pageIndex, int pageSize, String status) async {
    return await apiClient.postData(AppConstants.containersUrl, {
      "type": "BAG",
      "status": status, // "draft" for Open, "closed" for Closed
      "pageIndex": pageIndex,
      "pageSize": pageSize
    });
  }

  Future<Response> getAddressBook(int pageIndex, int pageSize) async {
    return await apiClient.postData(AppConstants.addressBookUrl, {
      "scope": "destination",
      "pageIndex": pageIndex,
      "pageSize": pageSize
    });
  }

  Future<Response> getSortationRules(int pageIndex, int pageSize) async {
    return await apiClient.postData(AppConstants.sortationRulesUrl, {
      "scopes": ["destination"],
      "entity": "JFK",
      "excludeEntityAll": true,
      "pageIndex": pageIndex,
      "pageSize": pageSize
    });
  }

  Future<Response> getOpenContainer(String number, String type, DateTime from, DateTime to) async {
    return await apiClient.postData(AppConstants.getOpenContainerUrl, {
      "createdOn": {
        "from": from.toUtc().toIso8601String(),
        "to": to.toUtc().toIso8601String()
      },
      "number": number,
      "type": type
    });
  }

  Future<Response> searchPackages(List<String> trackingNumbers, DateTime from, DateTime to) async {
    return await apiClient.postData(AppConstants.searchUrl, {
      "createdOn": { "from": from.toUtc().toIso8601String(),
        "to": to.toUtc().toIso8601String()},
      "trackingNumbers": trackingNumbers
    });
  }


  Future<Response> addToContainer(List<String> trackingNumbers, String containerTrackingNumber, DateTime from, DateTime to) async {
    return await apiClient.postData(AppConstants.addToContainerUrl, {
      "trackingNumbers": trackingNumbers,
      "containerTrackingNumber": containerTrackingNumber,
      "createdOn": { "from": from.toUtc().toIso8601String(),
        "to": to.toUtc().toIso8601String()},
      "addSortedTrace": true
    });
  }

  Future<Response> updateContainer({
    required String number,
    required String type,
    required double weightValue, // Changed from int
    required String weightUnit,
    required double length, // Changed from int
    required double width, // Changed from int
    required double height, // Changed from int
    required String dimensionsUnit,
    required bool closeContainer,
    String? sortationRuleCode,
    required String entity,
  }) async {
    return await apiClient.postData(AppConstants.updateContainerUrl, {
      "number": number,
      "type": type,
      "weight": {
        "value": weightValue,
        "unit": weightUnit,
      },
      "dimensions": {
        "length": length,
        "width": width,
        "height": height,
        "unit": dimensionsUnit,
      },
      "closeContainer": closeContainer,
      "sortationRuleCode": sortationRuleCode ?? "",
      "entity": entity,
    });
  }

  Future<Response> createContainer({
    required String user,
    required String tenant,
    required String channel,
    required String containerNumber,
    required String entity,
    String? flightNumber,
    required String type,
    required String description,
    required String shipDate,
    required Map<String, dynamic> consignee,
    required Map<String, dynamic> shipper,
    required String accountNumber,
    required String accountEntity,
    required double weightValue, // Changed from int
    required String weightUnit,
    required double length, // Changed from int
    required double width, // Changed from int
    required double height, // Changed from int
    required String dimensionsUnit,
  }) async {

    print({
      // "call_Context": {
      //   "user": user,
      //   "tenant": tenant,
      //   "channel": channel,
      // },
      // "payload": {
        "container_number": {
          "number": containerNumber,
        },
        "entity": entity,
        "references": flightNumber != null ? [
          {
            "type": "FlightNo",
            "value": flightNumber,
          }
        ] : [],
        "type": type,
        "description": description,
        "extended_properties": {
          "ship_date": shipDate,
          "consignee": consignee,
          "shipper": shipper,
          "account": {
            "number": accountNumber,
            "entity": accountEntity,
          },
          "weight": {
            "value": weightValue,
            "unit": weightUnit,
          },
          "dimensions": {
            "length": length,
            "width": width,
            "height": height,
            "unit": dimensionsUnit,
          },
        },
      // },
    });

    return await apiClient.postData(AppConstants.createContainerUrl, {
      // "call_Context": {
      //   "user": user,
      //   "tenant": tenant,
      //   "channel": channel,
      // },
      // "payload": {
        "container_number": {
          "number": containerNumber,
        },
        "entity": entity,
        "references": flightNumber != null ? [
          {
            "type": "FlightNo",
            "value": flightNumber,
          }
        ] : [],
        "type": type,
        "description": description,
        "extended_properties": {
          "ship_date": shipDate,
          "consignee": consignee,
          "shipper": shipper,
          "account": {
            "number": accountNumber,
            "entity": accountEntity,
          },
          "weight": {
            "value": weightValue,
            "unit": weightUnit,
          },
          "dimensions": {
            "length": length,
            "width": width,
            "height": height,
            "unit": dimensionsUnit,
          },
        },
      // },
    });
  }

  Future<Response> removeParcels({
    required String trackingNumber,
    required String scheme,
    required String containerNumber,
  }) async {

    print({
      "packageTrackingNumbers": [
        {
          "scheme": scheme,
          "value": trackingNumber,
        }
      ],
      "containerNumber": containerNumber,
    });

    return await apiClient.postData(AppConstants.removeParcelsUrl, {
      "packageTrackingNumbers": [
        {
          "scheme": scheme,
          "value": trackingNumber,
        }
      ],
      "containerNumber": containerNumber,
    });
  }
}
