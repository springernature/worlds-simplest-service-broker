package broker

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
    "github.com/cloudfoundry-community/go-cfclient"
	"code.cloudfoundry.org/lager"
	"github.com/pivotal-cf/brokerapi"
)

type BrokerImpl struct {
	Logger    lager.Logger
	Config    Config
	Instances map[string]brokerapi.GetInstanceDetailsSpec
	Bindings  map[string]brokerapi.GetBindingSpec
    Cflogin   *cfclient.Config
}

type Config struct {
	ServiceName    string
	ServicePlan    string
	BaseGUID       string
	Credentials    interface{}
	Tags           string
	ImageURL       string
	Free           bool
	ServiceDescription string
	FakeAsync    bool
	FakeStateful bool
	SysLogDrainURL string
}

func NewBrokerImpl(logger lager.Logger) (bkr *BrokerImpl) {
	var credentials interface{}
	json.Unmarshal([]byte(getEnvWithDefault("CREDENTIALS", "{\"port\": \"4000\"}")), &credentials)
	fmt.Printf("Credentials: %v\n", credentials)

	return &BrokerImpl{
		Logger:    logger,
		Instances: map[string]brokerapi.GetInstanceDetailsSpec{},
		Bindings:  map[string]brokerapi.GetBindingSpec{},
		Cflogin: &cfclient.Config{
   			ApiAddress:   "https://api.dev.cf.springer-sbm.com",
    		Username:     "admin",
    		Password:     "JtEGbqA1qk",
  		 },
		Config: Config{
			BaseGUID:    getEnvWithDefault("BASE_GUID", "29140B3F-0E69-4C7E-8A35"),
			ServiceName: getEnvWithDefault("SERVICE_NAME", "some-service-name"),
			ServicePlan: getEnvWithDefault("SERVICE_PLAN_NAME", "shared"),
			ServiceDescription: getEnvWithDefault("SERVICE_DESCRIPTION", "Shared service for ..."),
			Credentials: credentials,
			Tags:        getEnvWithDefault("TAGS", "shared,GCP_ES_Logger"),
			ImageURL:    os.Getenv("IMAGE_URL"),
			Free:        true,
            SysLogDrainURL: getEnvWithDefault("SYSLOG_DRAIN_URL", "syslog://10.230.11.186:5514"),
			FakeAsync:    os.Getenv("FAKE_ASYNC") == "true",
			FakeStateful: os.Getenv("FAKE_STATEFUL") == "true",
		},
	}
}

func getEnvWithDefault(key, defaultValue string) string {
	if os.Getenv(key) == "" {
		return defaultValue
	}
	return os.Getenv(key)
}

func (bkr *BrokerImpl) Services(ctx context.Context) ([]brokerapi.Service, error) {
	return []brokerapi.Service{
		brokerapi.Service{
			ID:                   bkr.Config.BaseGUID + "-service-" + bkr.Config.ServiceName,
			Name:                 bkr.Config.ServiceName,
			Description:          "Shared service for sending logs to ES in GCP",
			Bindable:             true,
			Requires: "syslog_drain",
			InstancesRetrievable: bkr.Config.FakeStateful,
			BindingsRetrievable:  bkr.Config.FakeStateful,
			Metadata: &brokerapi.ServiceMetadata{
				DisplayName: bkr.Config.ServiceName,
				ImageUrl:    bkr.Config.ImageURL,
			},
			Plans: []brokerapi.ServicePlan{
				brokerapi.ServicePlan{
					ID:          bkr.Config.BaseGUID + "-plan-" + bkr.Config.ServicePlan,
					Name:        bkr.Config.ServicePlan,
					Description: "Shared service for sending logs to ES in GCP",
					Free:        &bkr.Config.Free,
				},
			},
		},
	}, nil
}

func (bkr *BrokerImpl) Provision(ctx context.Context, instanceID string, details brokerapi.ProvisionDetails, asyncAllowed bool) (brokerapi.ProvisionedServiceSpec, error) {
	var parameters interface{}
	json.Unmarshal(details.GetRawParameters(), &parameters)
	bkr.Instances[instanceID] = brokerapi.GetInstanceDetailsSpec{
		ServiceID:  details.ServiceID,
		PlanID:     details.PlanID,
		Parameters: parameters,
	}
	return brokerapi.ProvisionedServiceSpec{
		IsAsync: bkr.Config.FakeAsync,
	}, nil
}

func (bkr *BrokerImpl) Deprovision(ctx context.Context, instanceID string, details brokerapi.DeprovisionDetails, asyncAllowed bool) (brokerapi.DeprovisionServiceSpec, error) {
	return brokerapi.DeprovisionServiceSpec{
		IsAsync: bkr.Config.FakeAsync,
	}, nil
}

func (bkr *BrokerImpl) GetInstance(ctx context.Context, instanceID string) (spec brokerapi.GetInstanceDetailsSpec, err error) {
	if val, ok := bkr.Instances[instanceID]; ok {
		return val, nil
	}
	err = brokerapi.NewFailureResponse(fmt.Errorf("Unknown instance ID %s", instanceID), 404, "get-instance")
	return
}

func (bkr *BrokerImpl) Bind(ctx context.Context, instanceID string, bindingID string, details brokerapi.BindDetails, asyncAllowed bool) (brokerapi.Binding, error) {
	var parameters interface{}
	appId := details.AppGUID
	envVarF2S := make(map[string]interface{})
    envVarF2S["F2S_DISABLE_LOGGING"]= "HOLY SHIT"
    client, _ := cfclient.NewClient(bkr.Cflogin)
    aur := cfclient.AppUpdateResource{Environment: envVarF2S}
    updateResp, err := client.UpdateApp(appId, aur)
    fmt.Println("AppID: ", appId, "updateResponse: ", updateResp, "error: ", err )
	json.Unmarshal(details.GetRawParameters(), &parameters)
	bkr.Bindings[bindingID] = brokerapi.GetBindingSpec{
		Credentials: bkr.Config.Credentials,
		Parameters:  parameters,
	}
	return brokerapi.Binding{
		Credentials: bkr.Config.Credentials,
		SyslogDrainURL: "syslog://10.230.11.186:5514",
	}, nil
}

func (bkr *BrokerImpl) Unbind(ctx context.Context, instanceID string, bindingID string, details brokerapi.UnbindDetails, asyncAllowed bool) (brokerapi.UnbindSpec, error) {
	return brokerapi.UnbindSpec{}, nil
}

func (bkr *BrokerImpl) GetBinding(ctx context.Context, instanceID string, bindingID string) (spec brokerapi.GetBindingSpec, err error) {
	if val, ok := bkr.Bindings[bindingID]; ok {
		return val, nil
	}
	err = brokerapi.NewFailureResponse(fmt.Errorf("Unknown binding ID %s", bindingID), 404, "get-binding")
	return
}

func (bkr *BrokerImpl) Update(ctx context.Context, instanceID string, details brokerapi.UpdateDetails, asyncAllowed bool) (brokerapi.UpdateServiceSpec, error) {
	return brokerapi.UpdateServiceSpec{
		IsAsync: bkr.Config.FakeAsync,
	}, nil
}

func (bkr *BrokerImpl) LastOperation(ctx context.Context, instanceID string, details brokerapi.PollDetails) (brokerapi.LastOperation, error) {
	return brokerapi.LastOperation{
		State: brokerapi.Succeeded,
	}, nil
}

func (bkr *BrokerImpl) LastBindingOperation(ctx context.Context, instanceID string, bindingID string, details brokerapi.PollDetails) (brokerapi.LastOperation, error) {
	panic("not implemented")
}
