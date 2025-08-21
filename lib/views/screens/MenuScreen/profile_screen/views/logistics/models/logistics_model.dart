class LogisticsData {
  final String? pickupAddress;
  final String? pickupLatitude;
  final String? pickupLongitude;
  final bool? pickUp;
  final bool? tshirtReceived;
  final bool? certificate;
  final bool? paymentReceived;
  final String? modeOfPayment;
  final String? transactionId;
  final int? tourId;

  LogisticsData({
    this.pickupAddress,
    this.pickupLatitude,
    this.pickupLongitude,
    this.pickUp,
    this.tshirtReceived,
    this.certificate,
    this.paymentReceived,
    this.modeOfPayment,
    this.transactionId,
    this.tourId,
  });

  factory LogisticsData.fromJson(Map<String, dynamic> json) {
    return LogisticsData(
      pickupAddress: json['pickupAddress'],
      pickupLatitude: json['pickupLatitude'],
      pickupLongitude: json['pickupLongitude'],
      pickUp: json['pick_up'],
      tshirtReceived: json['tshirt_received'],
      certificate: json['certificate'],
      paymentReceived: json['payment_received'],
      modeOfPayment: json['modeofpayment'],
      transactionId: json['transcation_id'],
      tourId: json['tour_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pickupAddress': pickupAddress,
      'pickupLatitude': pickupLatitude,
      'pickupLongitude': pickupLongitude,
      'pick_up': pickUp,
      'tshirt_received': tshirtReceived,
      'certificate': certificate,
      'payment_received': paymentReceived,
      'modeofpayment': modeOfPayment,
      'transcation_id': transactionId,
      'tour_id': tourId,
    };
  }

  @override
  String toString() {
    return 'LogisticsData(pickupAddress: $pickupAddress, pickupLatitude: $pickupLatitude, pickupLongitude: $pickupLongitude, pickUp: $pickUp, tshirtReceived: $tshirtReceived, certificate: $certificate, paymentReceived: $paymentReceived, modeOfPayment: $modeOfPayment, transactionId: $transactionId, tourId: $tourId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LogisticsData &&
        other.pickupAddress == pickupAddress &&
        other.pickupLatitude == pickupLatitude &&
        other.pickupLongitude == pickupLongitude &&
        other.pickUp == pickUp &&
        other.tshirtReceived == tshirtReceived &&
        other.certificate == certificate &&
        other.paymentReceived == paymentReceived &&
        other.modeOfPayment == modeOfPayment &&
        other.transactionId == transactionId &&
        other.tourId == tourId;
  }

  @override
  int get hashCode {
    return pickupAddress.hashCode ^
        pickupLatitude.hashCode ^
        pickupLongitude.hashCode ^
        pickUp.hashCode ^
        tshirtReceived.hashCode ^
        certificate.hashCode ^
        paymentReceived.hashCode ^
        modeOfPayment.hashCode ^
        transactionId.hashCode ^
        tourId.hashCode;
  }
} 