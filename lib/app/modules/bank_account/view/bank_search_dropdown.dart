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
    print('🔍 [DROPDOWN_DEBUG] Banks received: ${widget.banks.length}');
  }

  @override
  void didUpdateWidget(BankSearchDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.banks != widget.banks) {
      print('🔍 [DROPDOWN_DEBUG] Banks updated: ${widget.banks.length}');
      _filteredBanks = widget.banks;
      _filterBanks();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterBanks() {
    final query = _searchController.text.toLowerCase().trim();
    print('🔍 [DROPDOWN_DEBUG] Filtering banks with query: "$query"');
    print('🔍 [DROPDOWN_DEBUG] Total banks available: ${widget.banks.length}');
    
    setState(() {
      if (query.isEmpty) {
        _filteredBanks = widget.banks;
      } else {
        _filteredBanks = widget.banks.where((bank) {
          final name = bank.name?.toLowerCase() ?? '';
          final code = bank.code?.toLowerCase() ?? '';
          return name.contains(query) || code.contains(query);
        }).toList();
      }
    });
    
    print('🔍 [DROPDOWN_DEBUG] Filtered banks: ${_filteredBanks.length}');
  }

  void _showBankSelectionModal() {
    // Reset search when opening modal
    _searchController.clear();
    _filteredBanks = widget.banks;
    print('🔍 [DROPDOWN_DEBUG] Opening modal with ${widget.banks.length} banks');
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: Colors.grey[300],
                ),
              ),
              const SizedBox(height: 20),
              
              // Title
              const Text(
                'Selecione o Banco',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              
              // Search field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Digite o nome ou código do banco...',
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    style: const TextStyle(fontSize: 16),
                    onChanged: (value) {
                      setState(() {
                        _isSearching = value.isNotEmpty;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Results count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Text(
                        '${_filteredBanks.length} banco${_filteredBanks.length != 1 ? 's' : ''} encontrado${_filteredBanks.length != 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              // Banks list
              Expanded(
                child: _filteredBanks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isSearching ? Icons.search_off : Icons.account_balance,
                                size: 32,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _isSearching 
                                  ? 'Nenhum banco encontrado'
                                  : 'Carregando bancos...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isSearching 
                                  ? 'Tente usar outros termos de busca'
                                  : 'Aguarde um momento',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _filteredBanks.length,
                        itemBuilder: (context, index) {
                          final bank = _filteredBanks[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  print('🔍 [DROPDOWN_DEBUG] Bank selected: ${bank.name} - ${bank.code}');
                                  widget.onBankSelected(bank);
                                  Navigator.pop(context);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      // Bank icon
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.blue[50],
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.blue[200]!),
                                        ),
                                        child: Icon(
                                          Icons.account_balance,
                                          color: Colors.blue[600],
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      
                                      // Bank info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              bank.name ?? 'Banco sem nome',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Código: ${bank.code ?? 'N/A'}',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      // Bank code badge
                                      if (bank.code != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.grey[300]!),
                                          ),
                                          child: Text(
                                            bank.code!,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
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
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
        ],
        GestureDetector(
          onTap: _showBankSelectionModal,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Bank icon
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.account_balance,
                    color: Colors.blue[600],
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Text
                Expanded(
                  child: Text(
                    widget.controller.text.isEmpty
                        ? widget.hintText ?? 'Selecione um banco'
                        : widget.controller.text,
                    style: TextStyle(
                      color: widget.controller.text.isEmpty
                          ? Colors.grey[500]
                          : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ),
                
                // Arrow icon
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey[600],
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
