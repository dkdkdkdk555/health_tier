import 'package:flutter/material.dart';
import 'package:my_app/extension/screen_ratio_extension.dart';

class DocBodyWrite extends StatefulWidget {
  const DocBodyWrite({super.key});

  @override
  State<DocBodyWrite> createState() => _DocBodyWriteState();
}

class _DocBodyWriteState extends State<DocBodyWrite> {
  @override
  Widget build(BuildContext context) {
    final htio = ScreenRatio(context).heightRatio;
    final wtio = ScreenRatio(context).widthRatio;
  
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(47)),
        border: Border(
          left: BorderSide(width: 2 * wtio ,color: const Color(0xFFEEEEEE)),
          top: BorderSide(width: 2 * wtio, color: const Color(0xFFEEEEEE)),
          right: BorderSide(width: 2 * wtio, color: const Color(0xFFEEEEEE)),
          bottom: const BorderSide(color: Color(0xFFEEEEEE)),
        ),
      ),
      child: Column(
        children: [
          const Spacer(flex:2),
          Expanded(
            flex:1,
            child: Container(
              width: 40 * wtio,
              height: 4 * htio,
              decoration: ShapeDecoration(
                color: const Color(0xFFE6E6E6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                ),
              ),
            )
          ),
          const Spacer(flex:4),
          Expanded(
            flex: 180,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Row(
                children: [
                  const Spacer(flex:4),
                  Expanded(
                    flex: 67,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white
                      ),
                      child: Column(
                        children: [
                           const Expanded(
                            flex: 15,
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: 
                                Text(
                                  '2025.03.06 (목)',
                                  style: TextStyle(
                                    color: Color(0xFF777777),
                                    fontSize: 16.5,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w500
                                  ),
                                ),
                            ),
                          ),
                          Container(
                            height: 1,
                            decoration: const BoxDecoration(color: Color(0xFFEEEEEE)),
                          ),
                          const Spacer(flex: 12),
                          const Expanded(
                            flex: 24,
                            child: Row(
                              
                            ),
                          ),
                          const Spacer(flex: 12),
                           const Expanded(
                            flex: 24,
                            child: Row(
                              
                            ),
                          ),
                          const Spacer(flex: 12),
                           const Expanded(
                            flex: 24,
                            child: Row(
                              
                            ),
                          ),
                          const Spacer(flex: 12),
                           const Expanded(
                            flex: 48,
                            child: Row(
                              
                            ),
                          ),
                          const Spacer(flex: 12),
                           const Expanded(
                            flex: 17,
                            child: Row(
                              
                            ),
                          ),
                          const Spacer(flex: 16),
                          Container(
                            height: 1,
                            decoration: const BoxDecoration(color: Color(0xFFEEEEEE)),
                          ),
                          const Spacer(flex: 16),
                          const Expanded( // Text
                            flex: 9,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '당신의 하루를 평가해주세요.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Color(0xFF777777),
                                      fontSize: 14.7,
                                      fontFamily: 'Pretendard',
                                  ),
                                )
                              ],
                            ),
                          ),
                          const Spacer(flex: 8),
                          const Expanded(
                            flex: 31,
                            child: Row(
                              
                            ),
                          ),
                          const Spacer(flex: 20),
                          Expanded(
                            flex: 27,
                            child: Container(
                              color: Colors.lightBlue,
                              child: const Row(
                                
                              ),
                            ),
                          ),
                          const Spacer(flex: 18),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(flex:4),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}