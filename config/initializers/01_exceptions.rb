exceptions = %w(
  PermissionDenied
  AccountDoesNotExist
  IncorrectPassword
  ProhibitedOperator
  InvalidState
  DuplicatedPhone
  DuplicatedName
  InvalidCard
  InvalidMember
  InvalidBay
  CannotBeBlank
  DoesNotExist
  AlreadyInUse
  InvalidParameter
  UserNotFound
  UnactivatedUser
  IncorrectVerificationCode
  DuplicatedMembership
  DuplicatedBay
  InsufficientDeposit
  InvalidItem
  InvalidChargingType
  MemberExists
  DuplicatedReservation
  NoPrice
  NonUniqueMember
  InvalidBucket
  InvalidConfirmMethod
  InvalidUser
  OriginalPriceNotFound
  InvalidDiscount
  FrequentRequest
  TooManyRequest
  FullLesson
  AlreadyReserved
  OmnipotentRole
  InvalidTime
  ProductNotFound
  CourseNotFound
  InvalidProduct
  InvalidPayMethod
  InvalidLineItemType
  NotReadyToCheck
  InsufficientBalance
  OccupiedBay
  RefundAmountCanNotBeGreaterThanActualPrice
  AmountCanNotBeNegetive
)
exceptions.each{|e| Object.const_set(e, Class.new(StandardError))} 