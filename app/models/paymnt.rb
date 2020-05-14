class Paymnt < ApplicationRecord
    belongs_to :payable, polymorphic: true
    belongs_to :order
    self.table_name = "payments"
end
