package resource

import (
	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"
)

func Provider() *schema.Provider {
	return &schema.Provider{
		ResourcesMap: map[string]*schema.Resource{
			"spc_location_hdfs": ResourceLocationHDFS(),
		},
		DataSourcesMap: map[string]*schema.Resource{
			"datasource": dataSource(),
		},
	}
}
