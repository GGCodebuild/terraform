package resource

import (
	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"
)

func dataSource() *schema.Resource {
	return &schema.Resource{
		ReadContext: resourceRead,
		Schema: map[string]*schema.Schema{
			"_id": &schema.Schema{
				Type:     schema.TypeString,
				Required: true,
			},
		},
	}
}