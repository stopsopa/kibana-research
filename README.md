# manual queries to execute in kibana

GET _search
{
"query": {
"match_all": {}
}
}

GET _cat/indices

GET /_cat/templates