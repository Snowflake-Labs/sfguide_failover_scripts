#!/usr/bin/env python
import snowflake.connector
import streamlit as st
import pandas as pd
import streamlit_echarts as ste
import json

# Gets the version
ctx = snowflake.connector.connect(
    user=<user_name>,
    password=<password>,
    #account name value should be that of connection_url from the show connections command. Everything before snowflakecomputing.com
    account=<account_name>,
    session_parameters={
        'QUERY_TAG': 'Snowflake Summit 2022: Failover HoL'
    },
    warehouse='bi_reporting_wh',
    database='global_sales',
    role='product_manager'
    )

# Create a cursor object
cur = ctx.cursor()

#Query to power streamlit app
app_sql = """
select round(sum(o_totalprice)/1000,2) as value, 
       lower(c_mktsegment) as name 
       from 
       global_sales.online_retail.orders 
       inner join global_sales.online_retail.customer 
       on c_custkey = o_custkey 
       where o_orderdate between dateadd(day,-4,current_date) and current_date() 
       group by 2 
       order by 1 desc;
"""
#Query to get account name.
get_account_sql = "select current_account() as account_name;"

#Query to get region name.
get_region_sql = "select current_region() as region_name;"

#Query to get total sales transactions.
trans_count_sql = "select count(*) as transaction_count from sales..total_sales;"

#Query to get median qty.
median_qty_sql = "select median(quantity) as median_qty from sales..total_sales;"

#Query to get Last Update.
last_update_sql = "select max(last_update_time) as last_update from sales..total_sales;"

#Get Query results to power the main viz.
cur.execute(app_sql)
df = cur.fetch_pandas_all()

#Get account name.
cur.execute(get_account_sql)
account_name_json = cur.fetch_pandas_all().to_json(orient = 'records')
account_name = json.loads(account_name_json)[0]['ACCOUNT_NAME']

#Get region name.
cur.execute(get_region_sql)
region_name_json = cur.fetch_pandas_all().to_json(orient = 'records')
region_name = json.loads(region_name_json)[0]['REGION_NAME']

#Get total transactions.
cur.execute(trans_count_sql)
trans_count_json = cur.fetch_pandas_all().to_json(orient = 'records')
trans_count = json.loads(trans_count_json)[0]['TRANSACTION_COUNT']

#Get median qty.
cur.execute(median_qty_sql)
median_qty_json = cur.fetch_pandas_all().to_json(orient = 'records')
median_qty = json.loads(median_qty_json)[0]['MEDIAN_QTY']

#Get last update timestamp.
cur.execute(last_update_sql)
last_update_json = cur.fetch_pandas_all().to_json(orient = 'records')
last_update = json.loads(last_update_json)[0]['LAST_UPDATE']

#Adjust column case for our data frame to work well with streamlit extensions.
df_col_case = df.rename(columns = {'VALUE':'value','NAME':'name'})
df_chart_data = df_col_case.to_json(orient = 'records')
df_chart_data = json.loads(df_chart_data);

#Streamlit Extensions Pie chart visualization config.
options = {
    "tooltip": {"trigger": "item"},
    "legend": {"top": "5%", "left": "center"},
    "series": [
        {
            "name": "Revenue By Market Segment",
            "type": "pie",
            "radius": ["40%", "70%"],
            "avoidLabelOverlap": False,
            "itemStyle": {
                "borderRadius": 15,
                "borderColor": "#fff",
                "borderWidth": 7,
            },
            "label": {"show": False, "position": "center"},
            "emphasis": {
                "label": {"show": True, "fontSize": "40", "fontWeight": "bold"}
            },
            "labelLine": {"show": False},
            "data": df_chart_data,
        }
    ],
}

#st.sidebar.title("Real Time Sales Insight")
#original_title = '<p style="font-family:Courier; color:Blue; font-size: 20px;">Transaction Count</p>'
title_template = '<p style="color:Grey; font-size: 15px;">'
value_template = '<p style="color:Black; font-size: 25px;">'

account_title = title_template + 'Account Name:</p>'
region_title = title_template + 'Region Name:</p>'
transaction_title = title_template + 'Transaction Count:</p>'
median_title = title_template + 'Median Qty:</p>'
update_title = title_template + 'Last Updated Time:</p>'

account_value = value_template + account_name + '</p>'
region_value = value_template + region_name + '</p>'
transaction_value = value_template + str(trans_count) + '</p>'
median_value = value_template + str(median_qty) + '</p>'
update_time_value = value_template + str(last_update) + '</p>'

st.sidebar.markdown(account_title,unsafe_allow_html=True)
st.sidebar.markdown(account_value,unsafe_allow_html=True)
st.sidebar.markdown("***")
st.sidebar.markdown(region_title,unsafe_allow_html=True)
st.sidebar.markdown(region_value,unsafe_allow_html=True)
st.sidebar.markdown("***")
st.sidebar.markdown(transaction_title,unsafe_allow_html=True)
st.sidebar.markdown(transaction_value,unsafe_allow_html=True)
st.sidebar.markdown("***")
st.sidebar.markdown(median_title,unsafe_allow_html=True)
st.sidebar.markdown(median_value,unsafe_allow_html=True)
st.sidebar.markdown("***")
st.sidebar.markdown(update_title,unsafe_allow_html=True)
st.sidebar.markdown(update_time_value,unsafe_allow_html=True)

overview_text = """
This dashboard will help demonstrate revenue share per market segment 
as of yesterday. It is additionally highlighting information about the 
Snowflake deployment that is powering the pie-chart visualization, 
observe the name and region of your snowflake account. We will now 
stimulate a failover scenario by promoting our secondary account to 
primary and observe seamless failover while our ever so important data 
apps such as this continue to be powered by Snowflake, not just on a 
completely new region but also on a different cloud provider as well.   
"""
conclusion_text = """
Congratulations, on achieving cross-cloud cross-region 
replication in a matter of minutes. Remember, what happens in vegas doesn't 
necessarily need to stay in Vegas. Now go out, share this useful spear of 
knowledge that you now have in your quiver and go make your org resilient 
to region failures. 
"""
st.button("Refresh")
st.title("Snowflake + Streamlit")
st.header("Overview")
st.text(overview_text)

st.header("Revenue By Market Segment")
ste.st_echarts(
    options=options, height="500px"
)
st.header("Conclusion")
st.text(conclusion_text)
st.snow()
