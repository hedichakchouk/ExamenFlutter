// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:promenu/business_logic/local/local_cubit.dart';
//
// import '../../application_style/style_resources.dart';
//
// class LanguageDropdownButton extends StatelessWidget {
//   const LanguageDropdownButton({
//     super.key,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<LocalCubit, LocalState>(
//       buildWhen: (previousState, currentState) => previousState != currentState,
//       builder: (_, localState) {
//         return DropdownButton<Locale>(
//           value: localState.locale,
//           items: languages.map((Locale locale) {
//             return DropdownMenuItem<Locale>(
//               value: locale,
//               child: Row(
//                 children: [
//                   Image.asset(
//                     'assets/flags/${locale.countryCode}.png',
//                     height: 18.h,
//                   ),
//                   Padding(
//                     padding: EdgeInsets.only(right: 8.w, left: 10.w),
//                   ),
//                   Text(
//                     locale.countryCode!,
//                     style: StyleResources.DROPDOWN_TITLE_TEXT_STYLE,
//                   ),
//                 ],
//               ),
//             );
//           }).toList(),
//           onChanged: (value) {
//             BlocProvider.of<LocalCubit>(context).changeLocal(value!);
//           },
//         );
//       },
//     );
//   }
// }
//
// List<Locale> languages = [
//   const Locale('en', 'English'),
//   const Locale('fr', 'Francais'),
//   const Locale('ar', 'arabic'),
// ];
