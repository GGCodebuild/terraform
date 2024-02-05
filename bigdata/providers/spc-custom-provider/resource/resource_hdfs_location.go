package resource

import (
	"log"
	"os"
	"context"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/credentials"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/datasync"
	"github.com/hashicorp/terraform-plugin-sdk/v2/diag"
 	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"
)

func ResourceLocationHDFS() *schema.Resource {
	return &schema.Resource{
		CreateContext: resourceCreate,
		ReadContext:   resourceRead,
		UpdateContext: resourceUpdate,
		DeleteContext: resourceDelete,

		Schema: map[string]*schema.Schema{
			"access_key": &schema.Schema{
				Type:     schema.TypeString,
				Required: true,
			},
			"secret_key": &schema.Schema{
				Type:     schema.TypeString,
				Required: true,
			},
			"token": &schema.Schema{
				Type:     schema.TypeString,
				Required: true,
			},
			"agent_arns": &schema.Schema{
				Type:     schema.TypeString,
				Required: true,
			},
			"auth": &schema.Schema{
				Type:     schema.TypeString,
				Required: true,
			},
			"sub_directory": &schema.Schema{
				Type:     schema.TypeString,
				Required: true,
			},
			"kerberos_principal": &schema.Schema{
				Type:     schema.TypeString,
				Required: true,
			},
			"keytab_path": &schema.Schema{
				Type:     schema.TypeString,
				Required: true,
			},
			"krb5_path": &schema.Schema{
				Type:     schema.TypeString,
				Required: true,
			},
			"name_node_host": &schema.Schema{
				Type:     schema.TypeString,
				Required: true,
			},
			"name_node_port": &schema.Schema{
				Type:     schema.TypeInt,
				Required: true,
			},
			"replication_factor": &schema.Schema{
                Type:     schema.TypeString,
                Required: true,
            },
            "qop_configuration": &schema.Schema{
                Type:     schema.TypeList,
                Required: true,
                MaxItems: 1,
                Elem: &schema.Resource{
                    Schema: map[string]*schema.Schema{
                        "data_transfer_protection": {
                            Type:         schema.TypeString,
                            Optional:     true,
                        },
                        "rpc_protection": {
                            Type:         schema.TypeString,
                            Optional:     true,
                        },
                    },
                },
            },
            "tags": &schema.Schema{
                Type:     schema.TypeMap,
                Optional: true,
                Elem:     &schema.Schema{Type: schema.TypeString},
            },
		},
	}
}

func resourceCreate(ctx context.Context, d *schema.ResourceData, m interface{}) diag.Diagnostics {
	var diags diag.Diagnostics

	sess := accessAws(d)
	svc := datasync.New(sess)

	agentArns := d.Get("agent_arns").(string)
	auth := d.Get("auth").(string)
	subDirectory := d.Get("sub_directory").(string)
	kerberosPrincipal := d.Get("kerberos_principal").(string)

	keytabFilename := d.Get("keytab_path").(string)
	krb5Filename := d.Get("krb5_path").(string)
	tagListEntry := funcParseTags(d.Get("tags").(map[string]interface{}))
	qOPConfiguration := expandHDFSQOPConfiguration(d.Get("qop_configuration").([]interface{}))

	bKeytab, errKeytab := os.ReadFile(keytabFilename)
	bKrb5Conf, errKrb5Conf := os.ReadFile(krb5Filename)

	if errKeytab != nil {
		log.Fatal("Couldn't read the %s file: %v", keytabFilename, errKeytab)
	}

	if errKrb5Conf != nil {
		log.Fatal("Couldn't read the %s file: %v", krb5Filename, errKrb5Conf)
	}

	var hostName string
	var port int64
	hostName = d.Get("name_node_host").(string)
	port = int64(d.Get("name_node_port").(int))

	nameNodes := make([]*datasync.HdfsNameNode, 0)
	nameNode := &datasync.HdfsNameNode{
		Hostname: &hostName,
		Port:     &port,
	}
	nameNodes = append(nameNodes, nameNode)

	params := &datasync.CreateLocationHdfsInput{
		AgentArns:          []*string{&agentArns},
		NameNodes:          nameNodes,
		AuthenticationType: aws.String(auth),
		Subdirectory:       aws.String(subDirectory),
		KerberosPrincipal:  aws.String(kerberosPrincipal),
		KerberosKeytab:     bKeytab,
		KerberosKrb5Conf:   bKrb5Conf,
		Tags:       tagListEntry,
		QopConfiguration:   qOPConfiguration,
	}

	output, errRequest := svc.CreateLocationHdfsWithContext(ctx, params)

	if errRequest != nil {
		log.Fatal("Error when trying to create the Datasync HDFS Location: %v", errRequest)
	}

	log.Printf("LocationArn: %s", output.LocationArn)
	d.SetId(aws.StringValue(output.LocationArn))
	return diags
}

func resourceRead(ctx context.Context, d *schema.ResourceData, m interface{}) diag.Diagnostics {
	var diags diag.Diagnostics

	sess := accessAws(d)
    svc := datasync.New(sess)

	params := &datasync.DescribeLocationHdfsInput{
	    LocationArn: aws.String(d.Id()),
	}

  	output, errRequest := svc.DescribeLocationHdfsWithContext(ctx, params)

     if errRequest != nil {
         log.Printf("Error when trying to create the Datasync HDFS Location: %v", errRequest)
         d.SetId("")
         return diags
     }

    if d.IsNewResource(){
        log.Printf("Error when trying to create the Datasync HDFS Location New ID: %v", errRequest)
        d.SetId("")
        return diags
    }

    log.Printf("LocationArn: %s", output.LocationArn)

    d.SetId(aws.StringValue(output.LocationArn))
 	d.Set("arn", output.LocationArn)
 	d.Set("simple_user", output.SimpleUser)
 	d.Set("authentication_type", output.AuthenticationType)
 	d.Set("uri", output.LocationUri)
 	d.Set("block_size", output.BlockSize)
 	d.Set("replication_factor", output.ReplicationFactor)
 	d.Set("kerberos_principal", output.KerberosPrincipal)
 	d.Set("kms_key_provider_uri", output.KmsKeyProviderUri)

	return diags
}

func resourceUpdate(ctx context.Context, d *schema.ResourceData, m interface{}) diag.Diagnostics {
	var diags diag.Diagnostics

	sess := accessAws(d)
	svc := datasync.New(sess)

	input := &datasync.UpdateLocationHdfsInput{
		LocationArn: aws.String(d.Id()),
	}

	if d.HasChange("agent_arns") {
		agentArns := d.Get("agent_arns").(string)
		input.AgentArns = []*string{&agentArns}
	}

	if d.HasChange("auth") {
		input.AuthenticationType = aws.String(d.Get("auth").(string))
	}

	if d.HasChange("sub_directory") {
		input.Subdirectory = aws.String(d.Get("sub_directory").(string))
	}

	if d.HasChange("kerberos_principal") {
		input.KerberosPrincipal = aws.String(d.Get("kerberos_principal").(string))
	}

	if d.HasChange("kerberos_principal") {
		input.KerberosPrincipal = aws.String(d.Get("kerberos_principal").(string))
	}

	if d.HasChange("keytab_path") {
		keytabFilename := d.Get("keytab_path").(string)
		bKeytab, errKeytab := os.ReadFile(keytabFilename)
		if errKeytab != nil {
			log.Fatal("Couldn't read the %s file: %v", keytabFilename, errKeytab)
		}
		input.KerberosKeytab = bKeytab
	}

	if d.HasChange("krb5_path") {
		krb5Filename := d.Get("krb5_path").(string)
		bKrb5Conf, errKrb5Conf := os.ReadFile(krb5Filename)
		if errKrb5Conf != nil {
			log.Fatal("Couldn't read the %s file: %v", bKrb5Conf, errKrb5Conf)
		}
		input.KerberosKrb5Conf = bKrb5Conf
	}

	if d.HasChange("name_node_host") {
		var hostName string
		var port int64
		hostName = d.Get("name_node_host").(string)
		port = int64(d.Get("name_node_port").(int))

		nameNodes := make([]*datasync.HdfsNameNode, 0)
		nameNode := &datasync.HdfsNameNode{
			Hostname: &hostName,
			Port:     &port,
		}
		nameNodes = append(nameNodes, nameNode)

		input.NameNodes = nameNodes
	}

	if d.HasChange("name_node_port") {
		var hostName string
		var port int64
		hostName = d.Get("name_node_host").(string)
		port = int64(d.Get("name_node_port").(int))

		nameNodes := make([]*datasync.HdfsNameNode, 0)
		nameNode := &datasync.HdfsNameNode{
			Hostname: &hostName,
			Port:     &port,
		}
		nameNodes = append(nameNodes, nameNode)

		input.NameNodes = nameNodes
	}

	if d.HasChange("qop_configuration") {
	    input.QopConfiguration = expandHDFSQOPConfiguration(d.Get("qop_configuration").([]interface{}))
    }

    //Metodo não possuiu o atributo de Tags na atualização
    //if d.HasChange("tags") {
    //    input.Tags := funcParseTags(d.Get("tags").(map[string]interface{}))
    //}

	_, errRequest := svc.UpdateLocationHdfsWithContext(ctx, input)

	if errRequest != nil {
		log.Fatal("Error when trying to update the Datasync HDFS Location: %v", errRequest)
	}

	return diags
}

func resourceDelete(ctx context.Context, d *schema.ResourceData, m interface{}) diag.Diagnostics {
	var diags diag.Diagnostics

	sess := accessAws(d)
	svc := datasync.New(sess)

	input := &datasync.DeleteLocationInput{
		LocationArn: aws.String(d.Id()),
	}

	log.Printf("[DEBUG] Deleting DataSync Location HDFS: %s", input)
	_, errRequest := svc.DeleteLocationWithContext(ctx, input)

	if errRequest != nil {
		log.Fatal("Error when trying to delete the Datasync HDFS Location: %v", errRequest)
	}

	return diags
}

func expandHDFSQOPConfiguration(l []interface{}) *datasync.QopConfiguration {
	if len(l) == 0 || l[0] == nil {
		return nil
	}

	m := l[0].(map[string]interface{})

	qopConfig := &datasync.QopConfiguration{
		DataTransferProtection: aws.String(m["data_transfer_protection"].(string)),
		RpcProtection:          aws.String(m["rpc_protection"].(string)),
	}

	return qopConfig
}

func flattenHDFSNameNodes(nodes []*datasync.HdfsNameNode) []map[string]interface{} {
	dataResources := make([]map[string]interface{}, 0, len(nodes))

	for _, raw := range nodes {
		item := make(map[string]interface{})
		item["hostname"] = aws.StringValue(raw.Hostname)
		item["port"] = aws.Int64Value(raw.Port)

		dataResources = append(dataResources, item)
	}

	return dataResources
}

func flattenHDFSQOPConfiguration(qopConfig *datasync.QopConfiguration) []interface{} {
	if qopConfig == nil {
		return []interface{}{}
	}

	m := map[string]interface{}{
		"data_transfer_protection": aws.StringValue(qopConfig.DataTransferProtection),
		"rpc_protection":           aws.StringValue(qopConfig.RpcProtection),
	}

	return []interface{}{m}
}

func accessAws(d *schema.ResourceData) *session.Session {

    accessKey, secretKey, token := d.Get("access_key").(string), d.Get("secret_key").(string), d.Get("token").(string)

    sess, err := session.NewSessionWithOptions(session.Options{
        Profile: "default",
        Config: aws.Config{
            Region:      aws.String("sa-east-1"),
            Credentials: credentials.NewStaticCredentials(accessKey, secretKey, token),
        },
    })

    if err != nil {
        log.Fatal(err)
    }

    return sess

}

func funcParseTags(tags  map[string]interface{} ) []*datasync.TagListEntry {
    var tagListEntry []*datasync.TagListEntry
    for key, value := range tags {
        tagEntry := NewTagListEntry()
        tagEntry.SetKey(key)
        tagEntry.SetValue(value.(string))
        tagListEntry = append(tagListEntry, tagEntry)
    }

	return tagListEntry
}

func NewTagListEntry()(*datasync.TagListEntry){
    return &( datasync.TagListEntry{} );
}
