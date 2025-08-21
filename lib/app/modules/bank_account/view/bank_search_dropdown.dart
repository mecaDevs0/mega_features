import 'package:flutter/material.dart';
import 'package:mega_commons/mega_commons.dart';
import 'package:mega_commons_dependencies/mega_commons_dependencies.dart';

import '../../../../mega_features.dart';

class BankSearchDropdown extends StatefulWidget {
  const BankSearchDropdown({
    super.key,
    required this.controller,
    required this.banks,
    required this.onBankSelected,
    this.label,
    this.hintText,
    this.isRequired = false,
  });

  final TextEditingController controller;
  final List<Bank> banks;
  final Function(Bank) onBankSelected;
  final String? label;
  final String? hintText;
  final bool isRequired;

  @override
  State<BankSearchDropdown> createState() => _BankSearchDropdownState();
}

class _BankSearchDropdownState extends State<BankSearchDropdown> {
  final _searchController = TextEditingController();
  List<Bank> _filteredBanks = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _filteredBanks = widget.banks;
    _searchController.addListener(_filterBanks);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterBanks() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredBanks = widget.banks;
      } else {
        _filteredBanks = widget.banks.where((bank) {
          return bank.name?.toLowerCase().contains(query) == true ||
                 bank.code?.toLowerCase().contains(query) == true ||
                 bank.shortName?.toLowerCase().contains(query) == true;
        }).toList();
      }
    });
  }

  void _showBankSelectionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                height: 5,
                width: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.grey.withValues(alpha: 0.3),
                ),
              ),
              const SizedBox(height: 16),
              
              // Title
              const Text(
                'Selecione o Banco',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              
              // Search field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Pesquisar banco...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _isSearching = value.isNotEmpty;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              
              // Results count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      '${_filteredBanks.length} banco(s) encontrado(s)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              
              // Banks list
              Expanded(
                child: _filteredBanks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _isSearching 
                                  ? 'Nenhum banco encontrado'
                                  : 'Nenhum banco disponível',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredBanks.length,
                        itemBuilder: (context, index) {
                          final bank = _filteredBanks[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              bank.name ?? 'Banco sem nome',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              'Código: ${bank.code ?? 'N/A'}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            trailing: bank.shortName != null
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      bank.shortName!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  )
                                : null,
                            onTap: () {
                              widget.onBankSelected(bank);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Text(
            widget.label!,
            style: const TextStyle(
              color: AppColors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _showBankSelectionModal,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.controller.text.isEmpty
                        ? widget.hintText ?? 'Selecione um banco'
                        : widget.controller.text,
                    style: TextStyle(
                      color: widget.controller.text.isEmpty
                          ? Colors.grey[500]
                          : Colors.black,
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
