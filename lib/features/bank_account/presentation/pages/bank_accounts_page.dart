import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection_container.dart';
import '../../domain/entities/property_entity.dart';
import '../cubit/bank_account_cubit.dart';
import '../widgets/property_bank_card.dart';
import 'add_bank_account_page.dart';

class BankAccountsPage extends StatelessWidget {
  const BankAccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BankAccountCubit>()..loadProperties(),
      child: const _BankAccountsView(),
    );
  }
}

class _BankAccountsView extends StatelessWidget {
  const _BankAccountsView();

  Future<void> _openAddAccount(BuildContext context, {PropertyEntity? property}) async {
    final properties = context.read<BankAccountCubit>().state;
    List<PropertyEntity> all = [];
    if (properties is BankAccountLoaded) all = properties.properties;

    PropertyEntity? target = property;
    if (target == null) {
      if (all.isEmpty) return;
      target = all.length == 1 ? all.first : await _pickProperty(context, all);
      if (target == null) return;
    }

    if (!context.mounted) return;
    final added = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddBankAccountPage(propertyId: target!.id, propertyName: target.name),
      ),
    );

    if (added == true && context.mounted) {
      context.read<BankAccountCubit>().loadProperties();
    }
  }

  Future<PropertyEntity?> _pickProperty(BuildContext context, List<PropertyEntity> properties) {
    return showModalBottomSheet<PropertyEntity>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Choose a property', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              for (final p in properties)
                ListTile(
                  leading: const Icon(Icons.apartment_rounded, color: Color(0xFF2E5AF5)),
                  title: Text(p.name),
                  subtitle: Text('${p.location} · ${p.code}'),
                  onTap: () => Navigator.of(sheetContext).pop(p),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      body: SafeArea(
        child: BlocConsumer<BankAccountCubit, BankAccountState>(
          listener: (context, state) {
            if (state is BankAccountError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            final totalAccounts = state is BankAccountLoaded ? state.totalAccounts : 0;
            final totalProperties = state is BankAccountLoaded ? state.properties.length : 0;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Bank accounts',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                            if (state is BankAccountLoaded)
                              Text(
                                '$totalProperties properties · $totalAccounts accounts',
                                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.help_outline_rounded),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Builder(builder: (context) {
                    if (state is BankAccountLoading || state is BankAccountInitial) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is BankAccountError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(state.message, textAlign: TextAlign.center),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () => context.read<BankAccountCubit>().loadProperties(),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final loaded = state as BankAccountLoaded;
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE1EAFE),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline_rounded, color: Color(0xFF2E5AF5), size: 20),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Payouts for each property go to its primary account.',
                                  style: TextStyle(color: Color(0xFF1D3E9C), fontSize: 13.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        for (final property in loaded.properties)
                          PropertyBankCard(
                            property: property,
                            updatingAccountId: loaded.updatingAccountId,
                            onSetPrimary: (accountId) => context
                                .read<BankAccountCubit>()
                                .makePrimary(propertyId: property.id, accountId: accountId),
                            onAddAccount: () => _openAddAccount(context, property: property),
                            onEditAccount: (_) {},
                            onRemoveAccount: (_) {},
                          ),
                      ],
                    );
                  }),
                ),

                // SafeArea(
                //   top: false,
                //   child: Padding(
                //     padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                //     child: OutlinedButton(
                //       onPressed: () => _openAddAccount(context),
                //       style: OutlinedButton.styleFrom(
                //         minimumSize: const Size(double.infinity, 52),
                //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                //         side: const BorderSide(color: Color(0xFFD1D5DB)),
                //       ),
                //       child: const Row(
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         children: [
                //           Icon(Icons.add, color: Colors.black87),
                //           SizedBox(width: 8),
                //           Text('Add new bank account',
                //               style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),

                SizedBox(height: 60)
              ],
            );
          },
        ),
      ),
    );
  }
}
