import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invox/core/utils/responsive.dart';

void main() {
  group('Responsive Breakpoints and Context Extensions', () {
    testWidgets('Detects mobile viewport (< 768px)', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      late bool isMobile;
      late bool isTablet;
      late bool isDesktop;
      late bool isDesktopOrTablet;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              isMobile = context.isMobile;
              isTablet = context.isTablet;
              isDesktop = context.isDesktop;
              isDesktopOrTablet = context.isDesktopOrTablet;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(isMobile, isTrue);
      expect(isTablet, isFalse);
      expect(isDesktop, isFalse);
      expect(isDesktopOrTablet, isFalse);
    });

    testWidgets('Detects tablet viewport (768px - 1099px)', (tester) async {
      tester.view.physicalSize = const Size(800, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      late bool isMobile;
      late bool isTablet;
      late bool isDesktop;
      late bool isDesktopOrTablet;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              isMobile = context.isMobile;
              isTablet = context.isTablet;
              isDesktop = context.isDesktop;
              isDesktopOrTablet = context.isDesktopOrTablet;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(isMobile, isFalse);
      expect(isTablet, isTrue);
      expect(isDesktop, isFalse);
      expect(isDesktopOrTablet, isTrue);
    });

    testWidgets('Detects desktop/web viewport (>= 1100px)', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      late bool isMobile;
      late bool isTablet;
      late bool isDesktop;
      late bool isDesktopOrTablet;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              isMobile = context.isMobile;
              isTablet = context.isTablet;
              isDesktop = context.isDesktop;
              isDesktopOrTablet = context.isDesktopOrTablet;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(isMobile, isFalse);
      expect(isTablet, isFalse);
      expect(isDesktop, isTrue);
      expect(isDesktopOrTablet, isTrue);
    });

    testWidgets('ResponsiveLayout adapts dynamically based on width', (tester) async {
      // 1. Mobile
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: ResponsiveLayout(
            mobile: Text('Mobile View'),
            tablet: Text('Tablet View'),
            desktop: Text('Desktop View'),
          ),
        ),
      );

      expect(find.text('Mobile View'), findsOneWidget);
      expect(find.text('Tablet View'), findsNothing);
      expect(find.text('Desktop View'), findsNothing);

      // 2. Tablet
      tester.view.physicalSize = const Size(820, 1000);
      await tester.pumpAndSettle();

      expect(find.text('Mobile View'), findsNothing);
      expect(find.text('Tablet View'), findsOneWidget);
      expect(find.text('Desktop View'), findsNothing);

      // 3. Desktop
      tester.view.physicalSize = const Size(1280, 800);
      await tester.pumpAndSettle();

      expect(find.text('Mobile View'), findsNothing);
      expect(find.text('Tablet View'), findsNothing);
      expect(find.text('Desktop View'), findsOneWidget);
    });

    testWidgets('ResponsiveCenter limits width to maxContentWidth on large screens', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveCenter(
              maxWidth: 1200,
              child: SizedBox(
                key: Key('content_box'),
                width: double.infinity,
                height: 100,
              ),
            ),
          ),
        ),
      );

      final boxFinder = find.byKey(const Key('content_box'));
      final renderBox = tester.renderObject<RenderBox>(boxFinder);
      expect(renderBox.size.width, equals(1200.0));
    });
  });
}

