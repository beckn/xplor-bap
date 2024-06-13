import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xplor/features/multi_lang/domain/mappers/wallet/wallet_keys.dart';
import 'package:xplor/utils/extensions/string_to_string.dart';
import 'package:xplor/utils/utils.dart';

import '../../../../gen/assets.gen.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';
import '../../../../utils/extensions/font_style/font_styles.dart';
import '../../../../utils/extensions/space.dart';
import '../blocs/add_document_bloc/add_document_bloc.dart';
import '../blocs/add_document_bloc/add_document_event.dart';
import '../blocs/add_document_bloc/add_document_state.dart';

class TagsWidget extends StatefulWidget {
  const TagsWidget({super.key});

  @override
  State<TagsWidget> createState() => _TagsWidgetState();
}

class _TagsWidgetState extends State<TagsWidget> {
  final TextEditingController _textEditingController = TextEditingController();
  List<String> selected = [];
  Set<String> uniqueTags = {};

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return tagsContent();
  }

  Widget tagsContent() {
    return BlocListener<AddDocumentsBloc, AddDocumentsState>(
        listener: (context, state) {},
        child: BlocBuilder<AddDocumentsBloc, AddDocumentsState>(builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WalletKeys.enterTags.stringToString.titleBold(size: 14.sp, color: AppColors.grey64697a),
                  AppDimensions.small.vSpace(),
                  Container(
                    padding: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.grey100,
                          offset: Offset(0, 10),
                          blurRadius: 30,
                        ),
                      ],
                      border: Border.all(
                        color: AppColors.grey100,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(AppDimensions.small),
                    ),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _textEditingController,
                          onChanged: (tags) {
                            if (tags.trim().replaceAll(",", "").isNotEmpty && tags.contains(",")) {
                              selected.add(_textEditingController.text.replaceAll(",", ""));
                              context.read<AddDocumentsBloc>().add(FileTagsEvent(tags: selected));
                              _textEditingController.clear();
                              setState(() {
                                selected = selected;
                              });
                            }
                          },
                          onFieldSubmitted: (value) {
                            if (value.trim().replaceAll(",", "").isNotEmpty) {
                              selected.add(_textEditingController.text);
                              context.read<AddDocumentsBloc>().add(FileTagsEvent(tags: selected));
                              _textEditingController.clear();
                              setState(() {
                                selected = selected;
                              });
                            }
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9,]')),
                            LengthLimitingTextInputFormatter(16)
                            // Adjust as needed
                          ],
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.white,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 14.sp, horizontal: AppDimensions.smallXL.sp),
                            hintText: WalletKeys.includeComma.stringToString,
                            hintStyle: GoogleFonts.manrope(
                                fontWeight: FontWeight.w400, fontSize: 14.sp, color: AppColors.hintColor),
                          ),
                        ),
                        if (selected.isNotEmpty)
                          Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                                  child: Wrap(
                                    spacing: 5,
                                    runSpacing: 5,
                                    children: selected.map(
                                      (s) {
                                        uniqueTags = selected.toSet();
                                        return Container(
                                          decoration: BoxDecoration(
                                              color: AppColors.tagsColor.withOpacity(0.1),
                                              border: Border.all(
                                                color: AppColors.tagsColor,
                                                width: 1.5,
                                              ),
                                              borderRadius: BorderRadius.circular(49.27.sp)),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              AppDimensions.smallXL.hSpace(),
                                              s.titleSemiBold(size: 10.sp),
                                              GestureDetector(
                                                  onTap: () => setState(() {
                                                        selected.remove(s);
                                                        context
                                                            .read<AddDocumentsBloc>()
                                                            .add(FileTagsEvent(tags: selected));
                                                        setState(() {
                                                          selected = selected;
                                                        });
                                                      }),
                                                  child: Container(
                                                    color: Colors.transparent,
                                                    padding: const EdgeInsets.symmetric(
                                                      vertical: AppDimensions.small,
                                                      horizontal: AppDimensions.smallXL,
                                                    ),
                                                    child:
                                                        SvgPicture.asset(height: 8.w, width: 8.w, Assets.images.cross),
                                                  ))
                                            ],
                                          ),
                                        );
                                      },
                                    ).toList(),
                                  ),
                                ),
                              ),
                              AppDimensions.small.vSpace()
                            ],
                          )
                      ],
                    ),
                  ),
                  if (!(selected.length == uniqueTags.length) && state is! FileTagsErrorState)
                    Column(
                      children: [
                        WalletKeys.eachTagMustBeDifferent.stringToString
                            .titleSemiBold(size: 12.sp, color: AppColors.errorColor),
                        AppDimensions.smallXL.vSpace(),
                      ],
                    ),
                  if (state is FileTagsErrorState && state.message!.isNotEmpty)
                    Column(
                      children: [
                        state.message.toString().titleSemiBold(size: 12.sp, color: AppColors.errorColor),
                        AppDimensions.smallXL.vSpace(),
                      ],
                    ),
                ],
              ),
              AppDimensions.smallXL.vSpace(),
              Row(
                children: [
                  WalletKeys.suggestedTags.stringToString.titleRegular(size: 14.sp, color: AppColors.hintColor),
                  AppDimensions.extraSmall.hSpace(),
                  tagsWidget(tag: WalletKeys.scholarship.stringToString),
                  AppDimensions.extraSmall.hSpace(),
                  tagsWidget(tag: WalletKeys.admission.stringToString),
                  AppDimensions.extraSmall.hSpace(),
                  tagsWidget(tag: WalletKeys.job.stringToString),
                ],
              ),
            ],
          );
        }));
  }

  Widget tagsWidget({required String tag}) {
    return GestureDetector(
      onTap: () {
        _textEditingController.text = tag;
        selected.add(_textEditingController.text);
        context.read<AddDocumentsBloc>().add(FileTagsEvent(tags: selected));
        _textEditingController.clear();
        setState(() {
          selected = selected;
        });
      },
      child: Container(
        decoration:
            BoxDecoration(color: AppColors.grey64697a.withOpacity(0.1), borderRadius: BorderRadius.circular(49.27.sp)),
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.extraSmall, horizontal: AppDimensions.small),
        child: tag.titleSemiBold(size: 10.sp),
      ),
    );
  }
}