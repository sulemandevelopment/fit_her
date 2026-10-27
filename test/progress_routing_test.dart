// Verification test — Progress V2 paid-gating routing decision.
// Mirrors bottom_bar_screen.dart progress tab ternary without heavy deps.

import 'package:fitness_zone_2/data/models/login_response_model/login_response_model.dart';
import 'package:flutter_test/flutter_test.dart';

const String kV2 = 'ProgressScreenV2';
const String kV1 = 'ProgressScreenV1';

String pickProgressScreen(LoginModel? user) {
  return ((user?.status ?? false) ? kV2 : kV1);
}

LoginModel _mockUser({required bool status}) {
  return LoginModel.fromJson({
    'id': 1,
    'firstName': 'Test',
    'lastName': 'User',
    'email': 't@example.com',
    'phone': '',
    'accessToken': 'token',
    'userType': 'User',
    'adminId': 0,
    'status': status,
  });
}

void main() {
  test('paid user (status=true) → V2', () {
    expect(pickProgressScreen(_mockUser(status: true)), kV2);
  });

  test('free user (status=false) → V1', () {
    expect(pickProgressScreen(_mockUser(status: false)), kV1);
  });

  test('null logInUser (cold start) → V1', () {
    expect(pickProgressScreen(null), kV1);
  });

  test('fromJson roundtrip status=true → V2', () {
    final paid = _mockUser(status: true);
    expect(pickProgressScreen(paid), kV2);
  });
}
