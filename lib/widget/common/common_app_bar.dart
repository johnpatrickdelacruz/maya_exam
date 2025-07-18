import 'package:flutter/material.dart';
import 'package:new_maya_exam/utils/utils.dart';
import 'package:new_maya_exam/bloc/auth/auth_bloc.dart';
import 'package:new_maya_exam/bloc/auth/auth_event.dart';
import 'package:new_maya_exam/services/service_locator.dart';
import 'package:new_maya_exam/utils/app_strings.dart';

class CommonAppBar extends AppBar {
  CommonAppBar({
    super.key,
    required BuildContext context,
    required String title,
    bool showLogout = false,
  }) : super(
          title: Text(title),
          actions: showLogout
              ? [
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      Utils.showCommonDialog(
                        context: context,
                        title: AppStrings.dialogLogoutTitle,
                        content: AppStrings.dialogLogoutContent,
                        cancelText: AppStrings.buttonCancel,
                        okText: AppStrings.buttonLogout,
                        onCancel: () => Navigator.pop(context),
                        onOk: () {
                          Navigator.pop(context);
                          // Use AuthBloc to properly sign out
                          final authBloc = getIt<AuthBloc>();
                          authBloc.add(const AuthSignOutRequested());
                        },
                      );
                    },
                  ),
                ]
              : null,
        );
}
