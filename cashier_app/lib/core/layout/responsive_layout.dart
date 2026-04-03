import 'package:flutter/material.dart';

/// Breakpoint for switching between mobile and desktop layout.
const double kDesktopBreakpoint = 600;

/// Returns `true` when the shortest side is at least [kDesktopBreakpoint].
bool isWideScreen(BuildContext context) =>
    MediaQuery.sizeOf(context).shortestSide >= kDesktopBreakpoint;
