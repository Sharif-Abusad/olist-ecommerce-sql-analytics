import pandas as pd

input_file = "data/olist_orders_dataset.csv"
output_file = "data/olist_orders_clean.csv"

df = pd.read_csv(input_file)

date_columns = [
    "order_purchase_timestamp",
    "order_approved_at",
    "order_delivered_carrier_date",
    "order_delivered_customer_date",
    "order_estimated_delivery_date"
]

for col in date_columns:
    df[col] = pd.to_datetime(df[col], errors="coerce")

# Convert missing datetime values to the SQL NULL marker
df[date_columns] = df[date_columns].astype(object).where(
    df[date_columns].notna(),
    None
)

df.to_csv(
    output_file,
    index=False,
    na_rep="NULL"
)

print(f"Created: {output_file}")
print("\nMissing values:")
print(df[date_columns].isna().sum())