class QueryTemplate:
    def __init__(self, table_name, schema=None):
        self.table_name = table_name
        self.schema = schema
    
    def create_query_select(self, columns, latest_time):
        if not columns:
            column_str = "*"
        else:
            column_str = ", ".join(columns)
        
        query = f"""
            SELECT {column_str} 
            FROM {self.table_name}
            WHERE created_time > from_iso8601_timestamp('{latest_time}')
        """
        return query