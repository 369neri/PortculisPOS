import 'package:bloc_test/bloc_test.dart';
import 'package:cashier_app/features/cash_drawer/domain/entities/cash_drawer_session.dart';
import 'package:cashier_app/features/cash_drawer/domain/repositories/cash_drawer_repository.dart';
import 'package:cashier_app/features/cash_drawer/presentation/state/cash_drawer_cubit.dart';
import 'package:cashier_app/features/cash_drawer/presentation/state/cash_drawer_state.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<CashDrawerRepository>()])
import 'cash_drawer_cubit_test.mocks.dart';

void main() {
  late MockCashDrawerRepository repo;
  late CashDrawerCubit cubit;

  setUp(() {
    repo = MockCashDrawerRepository();
    cubit = CashDrawerCubit(repo);
  });

  tearDown(() => cubit.close());

  final now = DateTime(2026, 4, 4, 10);
  final session = CashDrawerSession(
    id: 1,
    openedAt: now,
    openingBalance: Price.from(5000),
  );

  group('load()', () {
    blocTest<CashDrawerCubit, CashDrawerState>(
      'emits [loading, open] when active session exists',
      setUp: () =>
          when(repo.getActiveSession()).thenAnswer((_) async => session),
      build: () => CashDrawerCubit(repo),
      act: (c) => c.load(),
      expect: () => [
        const CashDrawerLoading(),
        CashDrawerOpen(session),
      ],
    );

    blocTest<CashDrawerCubit, CashDrawerState>(
      'emits [loading, initial] when no active session',
      setUp: () =>
          when(repo.getActiveSession()).thenAnswer((_) async => null),
      build: () => CashDrawerCubit(repo),
      act: (c) => c.load(),
      expect: () => [
        const CashDrawerLoading(),
        const CashDrawerInitial(),
      ],
    );

    blocTest<CashDrawerCubit, CashDrawerState>(
      'emits [loading, error] when repo throws',
      setUp: () => when(repo.getActiveSession())
          .thenThrow(Exception('db error')),
      build: () => CashDrawerCubit(repo),
      act: (c) => c.load(),
      expect: () => [
        const CashDrawerLoading(),
        isA<CashDrawerError>(),
      ],
    );
  });

  group('openDrawer()', () {
    blocTest<CashDrawerCubit, CashDrawerState>(
      'creates session and emits open state',
      setUp: () {
        when(repo.openSession(any)).thenAnswer((_) async => 1);
        when(repo.getActiveSession()).thenAnswer((_) async => session);
      },
      build: () => CashDrawerCubit(repo),
      act: (c) => c.openDrawer(Price.from(5000)),
      expect: () => [CashDrawerOpen(session)],
      verify: (_) {
        verify(repo.openSession(any)).called(1);
      },
    );
  });

  group('closeDrawer()', () {
    blocTest<CashDrawerCubit, CashDrawerState>(
      'closes session and emits closed state',
      setUp: () {
        when(repo.closeSession(any, any)).thenAnswer((_) async {});
      },
      build: () => CashDrawerCubit(repo),
      seed: () => CashDrawerOpen(session),
      act: (c) => c.closeDrawer(Price.from(5200), notes: 'all good'),
      expect: () => [isA<CashDrawerClosed>()],
      verify: (_) {
        verify(repo.closeSession(1, any)).called(1);
      },
    );

    blocTest<CashDrawerCubit, CashDrawerState>(
      'does nothing when not in open state',
      build: () => CashDrawerCubit(repo),
      act: (c) => c.closeDrawer(Price.from(5000)),
      expect: () => <CashDrawerState>[],
    );
  });

  group('loadHistory()', () {
    blocTest<CashDrawerCubit, CashDrawerState>(
      'emits [loading, history] with sessions',
      setUp: () =>
          when(repo.getAllSessions()).thenAnswer((_) async => [session]),
      build: () => CashDrawerCubit(repo),
      act: (c) => c.loadHistory(),
      expect: () => [
        const CashDrawerLoading(),
        CashDrawerHistory([session]),
      ],
    );
  });
}
