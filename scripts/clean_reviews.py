import pandas as pd

input_file = "data/olist_order_reviews_dataset.csv"
output_file = "data/olist_order_reviews_clean.csv"

df = pd.read_csv(input_file)

date_columns = [
    "review_creation_date",
    "review_answer_timestamp"
]

for col in date_columns:
    df[col] = pd.to_datetime(df[col], errors="coerce")

df.to_csv(output_file, index=False)

print("Cleaning complete!")
print(df.info())
print("Rows:", len(df))