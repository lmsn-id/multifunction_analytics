import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/menu_item.dart';
import '../providers/theme_provider.dart';

class BottomNavigationWidget extends StatelessWidget {
  final MenuItem currentItem;
  final Widget child;

  const BottomNavigationWidget({
    super.key,
    required this.currentItem,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: _GlassBottomNavigation(currentItem: currentItem, isDark: isDark),
      ),
    );
  }
}

class _GlassBottomNavigation extends StatelessWidget {
  final MenuItem currentItem;
  final bool isDark;

  const _GlassBottomNavigation({
    required this.currentItem,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final items = MenuItem.values;
    final primaryColor = Theme.of(context).primaryColor;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          height: 72,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.white.withValues(alpha: 0.10),
                      Colors.white.withValues(alpha: 0.05),
                      Colors.white.withValues(alpha: 0.02),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.30),
                      Colors.white.withValues(alpha: 0.20),
                      Colors.white.withValues(alpha: 0.10),
                    ],
            ),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.40),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.40)
                    : Colors.black.withValues(alpha: 0.08),
                blurRadius: 30,
                spreadRadius: 2,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.20)
                    : Colors.white.withValues(alpha: 0.10),
                blurRadius: 50,
                spreadRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: items.map((item) {
              final selected = item == currentItem;

              return Expanded(
                flex: selected ? 2 : 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () {
                      if (!selected) {
                        context.go(item.route);
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                      decoration: BoxDecoration(
                        gradient: selected
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: isDark
                                    ? [
                                        Colors.white.withValues(alpha: 0.95),
                                        Colors.white.withValues(alpha: 0.85),
                                        Colors.white.withValues(alpha: 0.75),
                                      ]
                                    : [
                                        Colors.white,
                                        Colors.white.withValues(alpha: 0.95),
                                        Colors.white.withValues(alpha: 0.90),
                                      ],
                              )
                            : null,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: primaryColor.withValues(alpha: 0.25),
                                  blurRadius: 25,
                                  spreadRadius: 3,
                                  offset: const Offset(0, 10),
                                ),
                                BoxShadow(
                                  color: primaryColor.withValues(alpha: 0.15),
                                  blurRadius: 40,
                                  spreadRadius: 6,
                                  offset: const Offset(0, 5),
                                ),
                                BoxShadow(
                                  color: primaryColor.withValues(alpha: 0.05),
                                  blurRadius: 60,
                                  spreadRadius: 10,
                                  offset: const Offset(0, 0),
                                ),
                              ]
                            : [],
                      ),
                      child: Center(
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: selected ? 18 : 8,
                              vertical: selected ? 12 : 8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 350),
                                  transitionBuilder: (child, animation) =>
                                      ScaleTransition(
                                        scale:
                                            Tween<double>(
                                              begin: 0.7,
                                              end: 1.0,
                                            ).animate(
                                              CurvedAnimation(
                                                parent: animation,
                                                curve: Curves.easeOutBack,
                                              ),
                                            ),
                                        child: FadeTransition(
                                          opacity: Tween<double>(
                                            begin: 0.5,
                                            end: 1.0,
                                          ).animate(animation),
                                          child: child,
                                        ),
                                      ),
                                  child: Container(
                                    key: ValueKey('${selected}_${item.index}'),
                                    padding: EdgeInsets.all(selected ? 4 : 2),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: selected
                                          ? null
                                          : (isDark
                                                ? Colors.white.withValues(
                                                    alpha: 0.10,
                                                  )
                                                : Colors.black.withValues(
                                                    alpha: 0.05,
                                                  )),
                                      gradient: selected
                                          ? LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                primaryColor.withValues(
                                                  alpha: 0.15,
                                                ),
                                                primaryColor.withValues(
                                                  alpha: 0.05,
                                                ),
                                              ],
                                            )
                                          : null,
                                      boxShadow: selected
                                          ? [
                                              BoxShadow(
                                                color: primaryColor.withValues(
                                                  alpha: 0.20,
                                                ),
                                                blurRadius: 15,
                                                spreadRadius: 5,
                                                offset: const Offset(0, 0),
                                              ),
                                            ]
                                          : [],
                                    ),
                                    child: Icon(
                                      selected ? item.activeIcon : item.icon,
                                      size: selected ? 25 : 22,
                                      color: selected
                                          ? primaryColor
                                          : (isDark
                                                ? Colors.white
                                                : Colors.grey.shade800),
                                    ),
                                  ),
                                ),
                                AnimatedCrossFade(
                                  firstChild: const SizedBox(width: 0),
                                  secondChild: Padding(
                                    padding: const EdgeInsets.only(left: 12),
                                    child: Text(
                                      item.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.fade,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14.5,
                                        color: primaryColor,
                                        letterSpacing: 0.5,
                                        shadows: [
                                          Shadow(
                                            color: primaryColor.withValues(
                                              alpha: 0.10,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  crossFadeState: selected
                                      ? CrossFadeState.showSecond
                                      : CrossFadeState.showFirst,
                                  duration: const Duration(milliseconds: 350),
                                  sizeCurve: Curves.easeOutCubic,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
