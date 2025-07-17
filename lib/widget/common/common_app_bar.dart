import 'package:flutter/material.dart';
import 'package:new_maya_exam/utils/utils.dart';
import 'package:new_maya_exam/bloc/auth/auth_bloc.dart';
import 'package:new_maya_exam/bloc/auth/auth_event.dart';
import 'package:new_maya_exam/services/service_locator.dart';

class CommonAppBar extends AppBar {
  CommonAppBar({
    Key? key,
    required BuildContext context,
    required String title,
    bool showLogout = false,
  }) : super(
          key: key,
          title: Text(title),
          actions: showLogout
              ? [
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      Utils.showCommonDialog(
                        context: context,
                        title: 'Logout',
                        content: 'Are you sure you want to logout?',
                        cancelText: 'Cancel',
                        okText: 'Logout',
                        onCancel: () => Navigator.pop(context),
                        onOk: () {
                          Navigator.pop(context);
                          // Use AuthBloc to properly sign out
                          final authBloc = getIt<AuthBloc>();
                          authBloc.add(AuthSignOutRequested());
                        },
                      );
                    },
                  ),
                ]
              : null,
        );
}
