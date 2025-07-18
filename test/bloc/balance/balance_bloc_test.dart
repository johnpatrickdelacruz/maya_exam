import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:new_maya_exam/bloc/balance/balance_bloc.dart';
import 'package:new_maya_exam/bloc/balance/balance_event.dart';
import 'package:new_maya_exam/bloc/balance/balance_state.dart';
import 'package:new_maya_exam/repository/balance_repository.dart';
import 'package:new_maya_exam/models/balance_model.dart';
import 'package:new_maya_exam/models/transaction_model.dart';
import 'dart:async';

class MockBalanceRepository extends Mock
    implements BalanceRepositoryInterface {}

class MockBalanceModel extends Mock implements BalanceModel {}

class MockTransactionModel extends Mock implements TransactionModel {}

class FakeTransactionModel extends Fake implements TransactionModel {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeTransactionModel());
  });

  group('BalanceBloc', () {
    late BalanceBloc balanceBloc;
    late MockBalanceRepository mockBalanceRepository;
    late MockBalanceModel mockBalance;
    late StreamController<BalanceModel?> balanceStreamController;

    const testUid = 'test-uid-123';
    const testAmount = 5000.0;
    const newAmount = 7500.0;

    setUp(() {
      mockBalanceRepository = MockBalanceRepository();
      mockBalance = MockBalanceModel();
      balanceStreamController = StreamController<BalanceModel?>();

      // Setup mock balance properties
      when(() => mockBalance.userId).thenReturn(testUid);
      when(() => mockBalance.amount).thenReturn(testAmount);
      when(() => mockBalance.lastUpdated).thenReturn(DateTime.now());

      // Mock the watch balance stream
      when(() => mockBalanceRepository.watchUserBalance(any()))
          .thenAnswer((_) => balanceStreamController.stream);

      balanceBloc = BalanceBloc(mockBalanceRepository);
    });

    tearDown(() {
      balanceStreamController.close();
      balanceBloc.close();
    });

    // Test 1: Initial state
    test('initial state is BalanceInitial', () {
      expect(balanceBloc.state, isA<BalanceInitial>());
    });

    // Test 2: LoadBalance - success with existing balance
    blocTest<BalanceBloc, BalanceState>(
      'emits BalanceLoaded when LoadBalance succeeds with existing balance',
      build: () {
        when(() => mockBalanceRepository.getUserBalance(testUid))
            .thenAnswer((_) async => mockBalance);
        return balanceBloc;
      },
      act: (bloc) => bloc.add(const LoadBalance(testUid)),
      expect: () => [
        BalanceLoading(),
        BalanceLoaded(mockBalance),
      ],
    );

    // Test 3: LoadBalance - error
    blocTest<BalanceBloc, BalanceState>(
      'emits BalanceError when LoadBalance fails',
      build: () {
        when(() => mockBalanceRepository.getUserBalance(testUid))
            .thenThrow(Exception('Database error'));
        return balanceBloc;
      },
      act: (bloc) => bloc.add(const LoadBalance(testUid)),
      expect: () => [
        BalanceLoading(),
        const BalanceError('Exception: Database error'),
      ],
    );

    // Test 4: UpdateBalance - success
    blocTest<BalanceBloc, BalanceState>(
      'emits BalanceUpdated when UpdateBalance succeeds',
      build: () {
        final updatedBalance = MockBalanceModel();
        when(() => updatedBalance.userId).thenReturn(testUid);
        when(() => updatedBalance.amount).thenReturn(newAmount);
        when(() => updatedBalance.lastUpdated).thenReturn(DateTime.now());

        when(() => mockBalanceRepository.updateUserBalance(testUid, newAmount))
            .thenAnswer((_) async {});
        when(() => mockBalanceRepository.getUserBalance(testUid))
            .thenAnswer((_) async => updatedBalance);
        return balanceBloc;
      },
      act: (bloc) => bloc.add(const UpdateBalance(testUid, newAmount)),
      expect: () => [
        isA<BalanceUpdated>(),
      ],
    );

    // Test 5: UpdateBalance - error
    blocTest<BalanceBloc, BalanceState>(
      'emits BalanceError when UpdateBalance fails',
      build: () {
        when(() => mockBalanceRepository.updateUserBalance(testUid, newAmount))
            .thenThrow(Exception('Update failed'));
        return balanceBloc;
      },
      act: (bloc) => bloc.add(const UpdateBalance(testUid, newAmount)),
      expect: () => [
        const BalanceError('Exception: Update failed'),
      ],
    );

    // Test 6: GetCurrentBalance - creates new balance when none exists
    blocTest<BalanceBloc, BalanceState>(
      'creates and loads balance when GetCurrentBalance finds no existing balance',
      build: () {
        var callCount = 0;
        when(() => mockBalanceRepository.getUserBalance(testUid))
            .thenAnswer((_) async {
          callCount++;
          return callCount == 1 ? null : mockBalance;
        });
        when(() => mockBalanceRepository.createUserBalance(testUid, 10000.0))
            .thenAnswer((_) async {});
        return balanceBloc;
      },
      act: (bloc) => bloc.add(const GetCurrentBalance(testUid)),
      expect: () => [
        BalanceLoading(),
        BalanceLoaded(mockBalance),
      ],
    );

    // Test 7: GetCurrentBalance - loads existing balance
    blocTest<BalanceBloc, BalanceState>(
      'loads existing balance when GetCurrentBalance finds balance',
      build: () {
        when(() => mockBalanceRepository.getUserBalance(testUid))
            .thenAnswer((_) async => mockBalance);
        return balanceBloc;
      },
      act: (bloc) => bloc.add(const GetCurrentBalance(testUid)),
      expect: () => [
        BalanceLoading(),
        BalanceLoaded(mockBalance),
      ],
    );

    // Test 8: GetCurrentBalance - error during creation
    blocTest<BalanceBloc, BalanceState>(
      'emits BalanceError when GetCurrentBalance fails to create balance',
      build: () {
        when(() => mockBalanceRepository.getUserBalance(testUid))
            .thenAnswer((_) async => null);
        when(() => mockBalanceRepository.createUserBalance(testUid, 10000.0))
            .thenAnswer((_) async {});
        return balanceBloc;
      },
      act: (bloc) => bloc.add(const GetCurrentBalance(testUid)),
      expect: () => [
        BalanceLoading(),
        const BalanceError('Failed to create balance'),
      ],
    );

    // Test 9: SendMoney - success
    blocTest<BalanceBloc, BalanceState>(
      'emits BalanceUpdated when SendMoney succeeds',
      build: () {
        final currentBalance = MockBalanceModel();
        when(() => currentBalance.amount).thenReturn(testAmount);

        final updatedBalance = MockBalanceModel();
        when(() => updatedBalance.userId).thenReturn(testUid);
        when(() => updatedBalance.amount).thenReturn(testAmount - 1000.0);
        when(() => updatedBalance.lastUpdated).thenReturn(DateTime.now());

        // Set up sequential calls for getUserBalance
        var callCount = 0;
        when(() => mockBalanceRepository.getUserBalance(testUid))
            .thenAnswer((_) async {
          callCount++;
          return callCount == 1 ? currentBalance : updatedBalance;
        });
        when(() => mockBalanceRepository.recordTransaction(any()))
            .thenAnswer((_) async {});
        when(() => mockBalanceRepository.updateUserBalance(
            testUid, testAmount - 1000.0)).thenAnswer((_) async {});
        return balanceBloc;
      },
      act: (bloc) => bloc.add(const SendMoney(testUid, 1000.0, 'Test payment')),
      expect: () => [
        isA<BalanceUpdated>(),
      ],
    );

    // Test 10: SendMoney - insufficient balance
    blocTest<BalanceBloc, BalanceState>(
      'emits BalanceError when SendMoney has insufficient balance',
      build: () {
        final currentBalance = MockBalanceModel();
        when(() => currentBalance.amount).thenReturn(500.0);

        when(() => mockBalanceRepository.getUserBalance(testUid))
            .thenAnswer((_) async => currentBalance);
        return balanceBloc;
      },
      act: (bloc) => bloc.add(const SendMoney(testUid, 1000.0, 'Test payment')),
      expect: () => [
        const BalanceError('Insufficient balance'),
      ],
    );

    // Test 11: SendMoney - user balance not found
    blocTest<BalanceBloc, BalanceState>(
      'emits BalanceError when SendMoney finds no user balance',
      build: () {
        when(() => mockBalanceRepository.getUserBalance(testUid))
            .thenAnswer((_) async => null);
        return balanceBloc;
      },
      act: (bloc) => bloc.add(const SendMoney(testUid, 1000.0, 'Test payment')),
      expect: () => [
        const BalanceError('User balance not found'),
      ],
    );
  });
}
