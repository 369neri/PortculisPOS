import 'package:cashier_app/features/cash_drawer/presentation/state/cash_drawer_cubit.dart';
import 'package:cashier_app/features/cash_drawer/presentation/state/cash_drawer_state.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

void main() {
  late TestDeps deps;

  setUp(() {
    deps = TestDeps();
  });

  tearDown(() => deps.dispose());

  group('Cash drawer flow (full stack)', () {
    test('open → load → close → verify history', () async {
      final cubit = CashDrawerCubit(deps.cashDrawerRepo);

      // Initially no active session
      await cubit.load();
      expect(cubit.state, isA<CashDrawerInitial>());

      // Open drawer with 10000 subunits (e.g. $100.00)
      await cubit.openDrawer(Price(BigInt.from(10000)));
      expect(cubit.state, isA<CashDrawerOpen>());
      final openState = cubit.state as CashDrawerOpen;
      expect(openState.session.openingBalance, Price(BigInt.from(10000)));
      expect(openState.session.isOpen, isTrue);
      expect(openState.session.id, isNotNull);

      // Close drawer with counted balance of 12500
      await cubit.closeDrawer(
        Price(BigInt.from(12500)),
        notes: 'End of shift',
      );
      expect(cubit.state, isA<CashDrawerClosed>());
      final closedState = cubit.state as CashDrawerClosed;
      expect(closedState.session.closingBalance, Price(BigInt.from(12500)));
      expect(closedState.session.notes, 'End of shift');
      expect(closedState.session.isOpen, isFalse);

      // Load should show no active session (drawer is closed)
      await cubit.load();
      expect(cubit.state, isA<CashDrawerInitial>());

      // History should have one session
      await cubit.loadHistory();
      expect(cubit.state, isA<CashDrawerHistory>());
      final history = (cubit.state as CashDrawerHistory).sessions;
      expect(history, hasLength(1));
      expect(history.first.openingBalance, Price(BigInt.from(10000)));
      expect(history.first.closingBalance, Price(BigInt.from(12500)));

      await cubit.close();
    });

    test('closing a non-open drawer is a no-op', () async {
      final cubit = CashDrawerCubit(deps.cashDrawerRepo);

      // No session open → closeDrawer should be a no-op
      await cubit.load();
      expect(cubit.state, isA<CashDrawerInitial>());

      await cubit.closeDrawer(Price(BigInt.from(5000)));
      // State should remain initial (no-op)
      expect(cubit.state, isA<CashDrawerInitial>());

      await cubit.close();
    });

    test('multiple sessions appear in history', () async {
      final cubit = CashDrawerCubit(deps.cashDrawerRepo);

      // First session
      await cubit.openDrawer(Price(BigInt.from(5000)));
      await cubit.closeDrawer(Price(BigInt.from(6000)));

      // Second session
      await cubit.openDrawer(Price(BigInt.from(7000)));
      await cubit.closeDrawer(Price(BigInt.from(7500)));

      await cubit.loadHistory();
      final sessions = (cubit.state as CashDrawerHistory).sessions;
      expect(sessions, hasLength(2));

      await cubit.close();
    });

    test('load detects a previously open session', () async {
      final cubit1 = CashDrawerCubit(deps.cashDrawerRepo);
      await cubit1.openDrawer(Price(BigInt.from(2000)));
      // Don't close — simulate app restart by creating a new cubit
      await cubit1.close();

      final cubit2 = CashDrawerCubit(deps.cashDrawerRepo);
      await cubit2.load();
      expect(cubit2.state, isA<CashDrawerOpen>());
      final session = (cubit2.state as CashDrawerOpen).session;
      expect(session.openingBalance, Price(BigInt.from(2000)));
      expect(session.isOpen, isTrue);

      await cubit2.close();
    });
  });
}
