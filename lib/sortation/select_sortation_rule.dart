import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:opsapp/sortation/repository/sortation_repo.dart';
import 'package:opsapp/utils/client_api.dart';
import 'package:opsapp/sortation/model/sortation_rule_model.dart';

class SelectSortationRuleScreen extends StatefulWidget {
  const SelectSortationRuleScreen({super.key});

  @override
  State<SelectSortationRuleScreen> createState() => _SelectSortationRuleScreenState();
}

class _SelectSortationRuleScreenState extends State<SelectSortationRuleScreen> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late SortationRepo _sortationRepo;
  List<Matches> _ruleList = [];
  bool _isLoading = false;
  bool _isMoreLoading = false;
  int _pageIndex = 0;
  final int _pageSize = 10;
  bool _hasNextPage = true;

  @override
  void initState() {
    super.initState();
    _sortationRepo = SortationRepo(apiClient: Get.find<ApiClient>());
    _fetchRules();
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
        _fetchRules(isLoadMore: true);
      }
    }
  }

  Future<void> _fetchRules({bool isLoadMore = false}) async {
    if (isLoadMore) {
      setState(() {
        _isMoreLoading = true;
      });
    } else {
      setState(() {
        _isLoading = true;
        _pageIndex = 0;
        _ruleList = [];
        _hasNextPage = true;
      });
    }

    try {
      int pageToFetch = isLoadMore ? _pageIndex + 1 : _pageIndex;
      Response response = await _sortationRepo.getSortationRules(pageToFetch, _pageSize);
      if (response.statusCode == 200) {
        SortationRuleModel model = SortationRuleModel.fromJson(response.body);
        List<Matches> newRules = model.matches ?? [];

        if (newRules.length < _pageSize) {
          _hasNextPage = false;
        }

        setState(() {
          if (isLoadMore) {
            _ruleList.addAll(newRules);
            _pageIndex++;
          } else {
            _ruleList = newRules;
          }
        });
      } else {
        Get.snackbar("Error", "Failed to fetch rules: ${response.statusText}");
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
    // Client-side search
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
          "Select Sortation Rule",
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

            // Sortation rule list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _ruleList.isEmpty
                      ? const Center(child: Text("No rules found"))
                      : ListView.builder(
                          controller: _scrollController,
                          itemCount: _ruleList.length + (_isMoreLoading ? 1 : 0),
                          itemBuilder: (_, index) {
                            if (index == _ruleList.length) {
                              return const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }

                            final rule = _ruleList[index];
                            
                            // Simple client-side filter
                            if (searchController.text.isNotEmpty) {
                              final query = searchController.text.toLowerCase();
                              final code = rule.code?.toLowerCase() ?? "";
                              final name = rule.name?.toLowerCase() ?? "";
                              if (!code.contains(query) && !name.contains(query)) {
                                return const SizedBox.shrink();
                              }
                            }

                            final displayString = "${rule.code ?? ''}     ${rule.name ?? ''}";

                            return GestureDetector(
                              onTap: () => Navigator.pop(context, displayString),
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
                                    fontSize: 16,
                                    height: 1.4,
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
