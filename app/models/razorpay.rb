class Razorpay  < ApplicationRecord
    has_one :payment, as: :payable
    belongs_to :order
end