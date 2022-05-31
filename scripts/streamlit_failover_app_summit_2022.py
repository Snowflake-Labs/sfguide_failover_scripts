#!/usr/bin/env python
import snowflake.connector
import streamlit as st
import pandas as pd
import streamlit_echarts as ste
import json

# Gets the version
ctx = snowflake.connector.connect(
    user='<username>',
    password='<password>',
    account='<account_name>',
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

st.text("Account Name:")
st.subheader(account_name)
st.text("Region Name:")
st.subheader(region_name)
st.header("Revenue By Market Segment")
ste.st_echarts(
    options=options, height="500px"
)
st.header("Conclusion")
st.text(conclusion_text)
st.snow()