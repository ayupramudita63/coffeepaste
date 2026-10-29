import 'package:coffee_paste/core/config/app_config.dart';
import 'package:coffee_paste/features/account/data/profile_mock_repository.dart';
import 'package:coffee_paste/features/auth/data/user_model.dart';
import 'package:coffee_paste/features/cart/cart_item_model.dart';
import 'package:coffee_paste/features/order/data/order_mock_repository.dart';
import 'package:coffee_paste/features/order/models/order_model.dart';
import 'package:coffee_paste/providers/order_provider.dart';
import 'package:coffee_paste/providers/user_provider.dart';
import 'package:coffee_paste/shared/models/product_model.dart';
import 'package:flutter_test/flutter_test.dart';

CartItemModel _cartItem() => CartItemModel(
      product: const ProductModel(
        id: '1',
        name: 'Latte',
        price: 20000,
        categoryId: 'coffee',
        categoryName: 'Coffee',
      ),
      size: 'Regular',
      ice: 'Normal',
      sugar: 'Normal',
      quantity: 2,
    );

void main() {
  group('OrderModel: pembayaran', () {
    test('respons mobile dengan QRIS belum lunas terbaca', () {
      final o = OrderModel.fromJson({
        'id': '#CP00010',
        'date': '2026-10-10T10:00:00',
        'orderType': 'Take Away',
        'status': 'menunggu',
        'paymentMethod': 'QRIS',
        'paid': false,
        'subtotal': 50000,
        'tax': 5500,
        'total': 55500,
        'qrisPayload': '000201...6304ABCD',
        'items': [
          {'name': 'Latte', 'qty': 1, 'price': 50000},
        ],
      });
      expect(o.paymentMethod, PaymentMethod.qris);
      expect(o.paid, isFalse);
      expect(o.qrisPayload, '000201...6304ABCD');
      expect(o.taxAmount, 5500);
      expect(o.canCancel, isTrue);
      expect(o.orderLabel, '#CP00010');
    });

    test('tunai lunas: uang diterima, kembalian, dan kasir terbaca', () {
      final o = OrderModel.fromJson({
        'id': '#CP00011',
        'date': '2026-10-10T10:00:00',
        'orderType': 'Dine In',
        'status': 'proses',
        'paymentMethod': 'Tunai (Cash)',
        'paid': true,
        'cashReceived': 60000,
        'cashierName': 'Shinta',
        'tax': 5500,
        'total': 55500,
        'items': [
          {'name': 'Latte', 'qty': 1, 'price': 50000},
        ],
      });
      expect(o.paymentMethod, PaymentMethod.cash);
      expect(o.paid, isTrue);
      expect(o.change, 4500);
      expect(o.cashierName, 'Shinta');
      expect(o.canCancel, isFalse, reason: 'sudah lunas / diproses');
      expect(o.qrisPayload, isNull);
    });

    test('hanya status menunggu dan belum lunas yang bisa dibatalkan', () {
      OrderModel make(String status, bool paid) => OrderModel.fromJson({
            'id': '#CP1',
            'status': status,
            'paid': paid,
            'items': const [],
          });
      expect(make('menunggu', false).canCancel, isTrue);
      expect(make('menunggu', true).canCancel, isFalse);
      expect(make('proses', false).canCancel, isFalse);
      expect(make('dibatalkan', false).canCancel, isFalse);
    });

    test('orderLabel tidak menggandakan tanda #', () {
      final o = OrderModel(
        orderNumber: 'CP001',
        date: DateTime(2026, 10, 10),
        orderType: 'Dine In',
        status: OrderStatus.received,
        items: const [],
        total: 0,
      );
      expect(o.orderLabel, '#CP001');
    });

    test('QR hilang dari salinan yang sudah lunas atau dibatalkan', () {
      final base = OrderModel(
        id: '#CP1',
        orderNumber: '#CP1',
        date: DateTime(2026, 10, 10),
        orderType: 'Dine In',
        status: OrderStatus.received,
        items: const [],
        total: 1000,
        qrisPayload: 'QR',
      );
      expect(base.copyWith(paid: true).qrisPayload, isNull);
      expect(base.copyWith(status: OrderStatus.cancelled).qrisPayload, isNull);
      expect(base.copyWith(reviewedItemIds: {'1'}).qrisPayload, 'QR');
    });
  });

  group('OrderProvider: pesan & batal (mock)', () {
    late OrderProvider provider;

    setUp(() {
      provider = OrderProvider(MockOrderRepository(latency: Duration.zero));
    });

    test('QRIS: pesanan menunggu pembayaran dengan QR', () async {
      final ok = await provider.createOrder(
        items: [_cartItem()],
        orderType: 'Pick Up',
        paymentMethod: PaymentMethod.qris,
      );
      final order = provider.lastCreatedOrder!;

      expect(ok, isTrue);
      expect(order.paymentMethod, PaymentMethod.qris);
      expect(order.paid, isFalse);
      expect(order.qrisPayload, isNotNull);
      expect(provider.orderById(order.id), isNotNull);
    });

    test('Tunai: pesanan menunggu dibayar ke kasir, tanpa QR', () async {
      await provider.createOrder(
        items: [_cartItem()],
        orderType: 'Dine In',
        paymentMethod: PaymentMethod.cash,
      );
      final order = provider.lastCreatedOrder!;

      expect(order.paymentMethod, PaymentMethod.cash);
      expect(order.paid, isFalse);
      expect(order.qrisPayload, isNull);
      expect(order.awaitingPayment, isTrue);
    });

    test('pesanan yang belum diproses bisa dibatalkan customer', () async {
      await provider.createOrder(
        items: [_cartItem()],
        orderType: 'Pick Up',
        paymentMethod: PaymentMethod.cash,
      );
      final id = provider.lastCreatedOrder!.id;

      final ok = await provider.cancelOrder(id);

      expect(ok, isTrue);
      expect(provider.orderById(id)!.status, OrderStatus.cancelled);
      expect(provider.orderById(id)!.qrisPayload, isNull);
    });

    test('pesanan batal tidak bisa dibatalkan lagi', () async {
      await provider.createOrder(
        items: [_cartItem()],
        orderType: 'Pick Up',
      );
      final id = provider.lastCreatedOrder!.id;
      await provider.cancelOrder(id);

      expect(await provider.cancelOrder(id), isFalse);
      expect(provider.submitError, isNotNull);
    });

    test('ID pesanan tak dikenal -> null', () {
      expect(provider.orderById('#TIDAK-ADA'), isNull);
    });
  });

  group('UserProvider: ganti email (mock)', () {
    late UserProvider user;

    setUp(() {
      user = UserProvider(MockProfileRepository(latency: Duration.zero));
      user.applyUser(const UserModel(
        id: '1',
        name: 'Ayu',
        email: AppConfig.demoEmail,
      ));
    });

    test('password salah ditolak', () async {
      final error = await user.requestEmailChange(
        newEmail: 'baru@mail.com',
        currentPassword: 'salah',
      );
      expect(error, isNotNull);
      expect(user.pendingEmail, isEmpty);
    });

    test('kirim kode lalu verifikasi: email berganti', () async {
      expect(
        await user.requestEmailChange(
          newEmail: 'baru@mail.com',
          currentPassword: AppConfig.demoPassword,
        ),
        isNull,
      );
      expect(user.pendingEmail, 'baru@mail.com');
      expect(user.email, AppConfig.demoEmail, reason: 'belum berganti');

      expect(await user.verifyEmailChange('000000'), isNotNull);
      expect(user.email, AppConfig.demoEmail);

      expect(
        await user.verifyEmailChange(MockProfileRepository.mockCode),
        isNull,
      );
      expect(user.email, 'baru@mail.com');
      expect(user.pendingEmail, isEmpty);
    });

    test('loadProfile tetap diterima setelah email berganti (cocok lewat ID)',
        () async {
      await user.requestEmailChange(
        newEmail: 'baru@mail.com',
        currentPassword: AppConfig.demoPassword,
      );
      await user.verifyEmailChange(MockProfileRepository.mockCode);

      await user.loadProfile();

      expect(user.email, 'baru@mail.com');
      expect(user.gender, 'Perempuan');
    });

    test('batalkan permintaan ganti email', () async {
      await user.requestEmailChange(
        newEmail: 'baru@mail.com',
        currentPassword: AppConfig.demoPassword,
      );

      expect(await user.cancelEmailChange(), isNull);
      expect(user.pendingEmail, isEmpty);
    });
  });
}
