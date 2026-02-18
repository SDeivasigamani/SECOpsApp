import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:opsapp/sortation/repository/sortation_repo.dart';
import 'package:opsapp/utils/client_api.dart';
import 'package:opsapp/sortation/model/address_book_model.dart';

class SelectAddressScreen extends StatefulWidget {
  const SelectAddressScreen({super.key});

  @override
  State<SelectAddressScreen> createState() => _SelectAddressScreenState();
}

class _SelectAddressScreenState extends State<SelectAddressScreen> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  late SortationRepo _sortationRepo;
  List<Matches> _addressList = [];
  bool _isLoading = false;
  bool _isMoreLoading = false;
  int _pageIndex = 0;
  final int _pageSize = 20;
  bool _hasNextPage = true;

  @override
  void initState() {
    super.initState();
    _sortationRepo = SortationRepo(apiClient: Get.find<ApiClient>());
    _fetchAddresses();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (_hasNextPage && !_isLoading && !_isMoreLoading) {
        _fetchAddresses(isLoadMore: true);
      }
    }
  }

  Future<void> _fetchAddresses({bool isLoadMore = false}) async {
    if (isLoadMore) {
      setState(() {
        _isMoreLoading = true;
      });
    } else {
      setState(() {
        _isLoading = true;
        _pageIndex = 0;
        _addressList = [];
        _hasNextPage = true;
      });
    }

    try {
      int pageToFetch = isLoadMore ? _pageIndex + 1 : _pageIndex;
      Response response = await _sortationRepo.getAddressBook(pageToFetch, _pageSize);
      if (response.statusCode == 200) {
        AddressBookModel model = AddressBookModel.fromJson(response.body);
        List<Matches> newAddresses = model.matches ?? [];

        if (newAddresses.length < _pageSize) {
          _hasNextPage = false;
        }

        setState(() {
          if (isLoadMore) {
            _addressList.addAll(newAddresses);
            _pageIndex++;
          } else {
            _addressList = newAddresses;
          }
        });
      } else {
        Get.snackbar("Error", "Failed to fetch addresses: ${response.statusText}");
      }
    } catch (e) {
      // print(e);
      Get.snackbar("Error", "An error occurred: $e");
    } finally {
      setState(() {
        _isLoading = false;
        _isMoreLoading = false;
      });
    }
  }

  void _search(String query) {
    // Client-side search for now as API search param is not specified
    // Ideally this should be server-side
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          "Select Address",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: searchController,
                onChanged: _search,
                decoration: const InputDecoration(
                  hintText: "Search here",
                  hintStyle: TextStyle(color: Colors.black45),
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 15),

            // List of addresses
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _addressList.isEmpty
                      ? const Center(child: Text("No addresses found"))
                      : ListView.builder(
                          controller: _scrollController,
                          itemCount: _addressList.length + (_isMoreLoading ? 1 : 0),
                          itemBuilder: (_, index) {
                            if (index == _addressList.length) {
                              return const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }

                            final addressEntry = _addressList[index];
                            final details = addressEntry.details;
                            
                            // Simple client-side filter
                            if (searchController.text.isNotEmpty) {
                              final query = searchController.text.toLowerCase();
                              final name = details?.name?.toLowerCase() ?? "";
                              final city = details?.address?.city?.toLowerCase() ?? "";
                              if (!name.contains(query) && !city.contains(query)) {
                                return const SizedBox.shrink();
                              }
                            }

                            final name = details?.name ?? "-";
                            final street = details?.address?.street?.join(", ") ?? "";
                            final city = details?.address?.city ?? "";
                            final state = details?.address?.state ?? "";
                            final country = details?.address?.country ?? "";
                            final postCode = details?.address?.postCode ?? "";
                            final email = (details?.emails != null && details!.emails!.isNotEmpty) 
                                ? details.emails!.first 
                                : "";
                            final phone = (details?.phones != null && details!.phones!.isNotEmpty) 
                                ? details.phones!.first 
                                : "";

                            final displayString = [
                              name,
                              street,
                              "$city, $state",
                              "$country - $postCode",
                              email,
                              phone
                            ].where((s) => s.isNotEmpty && s != ", " && s != " - ").join("\n");

                            return GestureDetector(
                              onTap: () {
                                Navigator.pop(context, displayString);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(18),
                                margin: const EdgeInsets.only(bottom: 14),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Text(
                                  displayString,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 15,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
