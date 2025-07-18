import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:new_maya_exam/widget/common/common_app_bar.dart';
import 'package:new_maya_exam/widget/common/common_bottom_sheet.dart';
import 'package:new_maya_exam/widget/common/common_button.dart';
import 'package:new_maya_exam/widget/common/common_text_field.dart';
import 'package:new_maya_exam/bloc/transaction/transaction_bloc.dart';
import 'package:new_maya_exam/bloc/transaction/transaction_event.dart';
import 'package:new_maya_exam/bloc/transaction/transaction_state.dart';
import 'package:new_maya_exam/services/service_locator.dart';
import 'package:new_maya_exam/utils/app_strings.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  late TransactionBloc _transactionBloc;

  @override
  void initState() {
    super.initState();
    _transactionBloc = getIt<TransactionBloc>();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _emailController.dispose();
    _transactionBloc.close();
    super.dispose();
  }

  void _submit() {
    final amountText = _amountController.text.trim();
    final email = _emailController.text.trim();
    final amount = double.tryParse(amountText);

    if (email.isEmpty) {
      showCommonBottomSheet(
        context: context,
        icon: Icons.error,
        iconColor: Colors.red,
        message: AppStrings.errorEnterRecipientEmail,
      );
      return;
    }

    if (amount == null || amount <= 0) {
      showCommonBottomSheet(
        context: context,
        icon: Icons.error,
        iconColor: Colors.red,
        message: AppStrings.errorEnterValidAmount,
      );
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      showCommonBottomSheet(
        context: context,
        icon: Icons.error,
        iconColor: Colors.red,
        message: AppStrings.errorUserNotAuthenticated,
      );
      return;
    }

    _transactionBloc.add(SendMoneyToUser(
      senderUid: currentUser.uid,
      recipientEmail: email,
      amount: amount,
      description: AppStrings.transactionDescriptionDefault,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _transactionBloc,
      child: BlocListener<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionSuccess) {
            showCommonBottomSheet(
              context: context,
              icon: Icons.check_circle,
              iconColor: Colors.green,
              message: state.message,
            );
            // Clear form after successful transaction
            _amountController.clear();
            _emailController.clear();
          } else if (state is TransactionError) {
            showCommonBottomSheet(
              context: context,
              icon: Icons.error,
              iconColor: Colors.red,
              message: state.message,
            );
          }
        },
        child: PopScope(
          canPop: true,
          onPopInvoked: (didPop) {
            if (!didPop) {
              context.pop();
            }
          },
          child: Scaffold(
            appBar: CommonAppBar(
                context: context,
                title: AppStrings.titleSendMoney,
                showLogout: true),
            body: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CommonTextField(
                    controller: _emailController,
                    label: AppStrings.labelRecipientEmail,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  CommonTextField(
                    controller: _amountController,
                    label: AppStrings.labelEnterAmount,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(AppStrings.regexAmountPattern)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  BlocBuilder<TransactionBloc, TransactionState>(
                    builder: (context, state) {
                      if (state is TransactionLoading) {
                        return const CircularProgressIndicator();
                      }
                      return CommonButton(
                        text: AppStrings.buttonSendMoney,
                        onPressed: _submit,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
