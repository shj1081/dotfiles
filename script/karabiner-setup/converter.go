package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"

	"gopkg.in/yaml.v3"
)

// KarabinerConfig represents the full structure of karabiner.json
type KarabinerConfig struct {
	Global   map[string]interface{} `json:"global"`
	Profiles []Profile              `json:"profiles"`
}

// Profile represents a Karabiner profile
type Profile struct {
	Name                 string                 `json:"name"`
	Selected             bool                   `json:"selected"`
	SimpleModifications  []interface{}          `json:"simple_modifications"`
	ComplexModifications ComplexModifications   `json:"complex_modifications"`
	Devices              []interface{}          `json:"devices"`
	FnFunctionKeys       []interface{}          `json:"fn_function_keys"`
	VirtualHidKeyboard   map[string]interface{} `json:"virtual_hid_keyboard,omitempty"`
}

// ComplexModifications contains parameters and rules
type ComplexModifications struct {
	Parameters map[string]interface{} `json:"parameters"`
	Rules      []Rule                 `json:"rules"`
}

// Rule represents a complex modification rule
type Rule struct {
	Description  string        `json:"description,omitempty"`
	Manipulators []Manipulator `json:"manipulators"`
}

// Manipulator defines key modifications
type Manipulator struct {
	Type         string                   `json:"type"`
	From         *From                    `json:"from,omitempty"`
	To           []map[string]interface{} `json:"to,omitempty"`
	ToIfAlone    []map[string]interface{} `json:"to_if_alone,omitempty"`
	ToAfterKeyUp []map[string]interface{} `json:"to_after_key_up,omitempty"`
	Conditions   []map[string]interface{} `json:"conditions,omitempty"`
	Description  string                   `json:"description,omitempty"`
}

// From defines the source key
type From struct {
	KeyCode   string                 `json:"key_code"`
	Modifiers map[string]interface{} `json:"modifiers,omitempty"`
}

// SimpleRulesConfig represents a simplified yaml structure for rules
type SimpleRulesConfig struct {
	Rules []SimpleRule `yaml:"rules"`
}

// SimpleRule defines a rule with manipulators
type SimpleRule struct {
	Description  string              `yaml:"description"`
	Manipulators []SimpleManipulator `yaml:"manipulators"`
}

// SimpleManipulator defines a simplified manipulator
type SimpleManipulator struct {
	Type         string            `yaml:"type"`
	Description  string            `yaml:"description,omitempty"`
	From         SimpleFrom        `yaml:"from"`
	To           []SimpleToAction  `yaml:"to,omitempty"`
	ToIfAlone    []SimpleToAction  `yaml:"to_if_alone,omitempty"`
	ToAfterKeyUp []SimpleToAction  `yaml:"to_after_key_up,omitempty"`
	Conditions   []SimpleCondition `yaml:"conditions,omitempty"`
}

// SimpleFrom defines the source key in a simplified format
type SimpleFrom struct {
	KeyCode       string   `yaml:"key_code"`
	MandatoryMods []string `yaml:"mandatory_mods,omitempty"`
	OptionalMods  []string `yaml:"optional_mods,omitempty"`
}

// SimpleToAction defines a simplified to action
type SimpleToAction struct {
	KeyCode     string          `yaml:"key_code,omitempty"`
	Modifiers   []string        `yaml:"modifiers,omitempty"`
	SetVariable *SimpleVariable `yaml:"set_variable,omitempty"`
}

// SimpleVariable for variable manipulation
type SimpleVariable struct {
	Name  string `yaml:"name"`
	Value int    `yaml:"value"`
}

// SimpleCondition defines a simplified condition
type SimpleCondition struct {
	Type              string   `yaml:"type"`
	Name              string   `yaml:"name,omitempty"`
	Value             int      `yaml:"value,omitempty"`
	BundleIdentifiers []string `yaml:"bundle_identifiers,omitempty"`
}

// Read karabiner.json from file
func readKarabinerConfig(filePath string) (KarabinerConfig, error) {
	var config KarabinerConfig

	data, err := ioutil.ReadFile(filePath)
	if err != nil {
		return config, err
	}

	err = json.Unmarshal(data, &config)
	if err != nil {
		return config, err
	}

	return config, nil
}

// Read simplified YAML rules
func readSimpleRules(filePath string) (SimpleRulesConfig, error) {
	var config SimpleRulesConfig

	data, err := ioutil.ReadFile(filePath)
	if err != nil {
		return config, err
	}

	err = yaml.Unmarshal(data, &config)
	if err != nil {
		return config, err
	}

	return config, nil
}

// Write config to karabiner.json
func writeKarabinerConfig(config KarabinerConfig, filePath string) error {
	data, err := json.MarshalIndent(config, "", "  ")
	if err != nil {
		return err
	}

	err = ioutil.WriteFile(filePath, data, 0644)
	if err != nil {
		return err
	}

	return nil
}

// Convert SimpleManipulator to Manipulator
func convertManipulator(simpleManip SimpleManipulator) Manipulator {
	manipulator := Manipulator{
		Type:        simpleManip.Type,
		Description: simpleManip.Description,
	}

	// Convert From
	from := From{
		KeyCode: simpleManip.From.KeyCode,
	}

	// Add modifiers if present
	if len(simpleManip.From.MandatoryMods) > 0 || len(simpleManip.From.OptionalMods) > 0 {
		from.Modifiers = make(map[string]interface{})

		if len(simpleManip.From.MandatoryMods) > 0 {
			from.Modifiers["mandatory"] = simpleManip.From.MandatoryMods
		}

		if len(simpleManip.From.OptionalMods) > 0 {
			from.Modifiers["optional"] = simpleManip.From.OptionalMods
		}
	}

	manipulator.From = &from

	// Convert To actions
	if len(simpleManip.To) > 0 {
		manipulator.To = make([]map[string]interface{}, 0)

		for _, to := range simpleManip.To {
			toMap := make(map[string]interface{})

			if to.KeyCode != "" {
				toMap["key_code"] = to.KeyCode
			}

			if len(to.Modifiers) > 0 {
				toMap["modifiers"] = to.Modifiers
			}

			if to.SetVariable != nil {
				toMap["set_variable"] = map[string]interface{}{
					"name":  to.SetVariable.Name,
					"value": to.SetVariable.Value,
				}
			}

			manipulator.To = append(manipulator.To, toMap)
		}
	}

	// Convert ToIfAlone actions
	if len(simpleManip.ToIfAlone) > 0 {
		manipulator.ToIfAlone = make([]map[string]interface{}, 0)

		for _, to := range simpleManip.ToIfAlone {
			toMap := make(map[string]interface{})

			if to.KeyCode != "" {
				toMap["key_code"] = to.KeyCode
			}

			if len(to.Modifiers) > 0 {
				toMap["modifiers"] = to.Modifiers
			}

			if to.SetVariable != nil {
				toMap["set_variable"] = map[string]interface{}{
					"name":  to.SetVariable.Name,
					"value": to.SetVariable.Value,
				}
			}

			manipulator.ToIfAlone = append(manipulator.ToIfAlone, toMap)
		}
	}

	// Convert ToAfterKeyUp actions
	if len(simpleManip.ToAfterKeyUp) > 0 {
		manipulator.ToAfterKeyUp = make([]map[string]interface{}, 0)

		for _, to := range simpleManip.ToAfterKeyUp {
			toMap := make(map[string]interface{})

			if to.KeyCode != "" {
				toMap["key_code"] = to.KeyCode
			}

			if len(to.Modifiers) > 0 {
				toMap["modifiers"] = to.Modifiers
			}

			if to.SetVariable != nil {
				toMap["set_variable"] = map[string]interface{}{
					"name":  to.SetVariable.Name,
					"value": to.SetVariable.Value,
				}
			}

			manipulator.ToAfterKeyUp = append(manipulator.ToAfterKeyUp, toMap)
		}
	}

	// Convert Conditions
	if len(simpleManip.Conditions) > 0 {
		manipulator.Conditions = make([]map[string]interface{}, 0)

		for _, cond := range simpleManip.Conditions {
			condMap := make(map[string]interface{})
			condMap["type"] = cond.Type

			if cond.Name != "" {
				condMap["name"] = cond.Name
				condMap["value"] = cond.Value
			}

			if len(cond.BundleIdentifiers) > 0 {
				condMap["bundle_identifiers"] = cond.BundleIdentifiers
			}

			manipulator.Conditions = append(manipulator.Conditions, condMap)
		}
	}

	return manipulator
}

// Convert SimpleRule to Rule
func convertRule(simpleRule SimpleRule) Rule {
	rule := Rule{
		Description:  simpleRule.Description,
		Manipulators: make([]Manipulator, 0),
	}

	for _, simpleManip := range simpleRule.Manipulators {
		manipulator := convertManipulator(simpleManip)
		rule.Manipulators = append(rule.Manipulators, manipulator)
	}

	return rule
}

func main() {
	// Define command line flags
	yamlPathPtr := flag.String("yaml", "", "Path to simplified YAML rules file")
	karabinerPathPtr := flag.String("karabiner", filepath.Join(os.Getenv("HOME"), "dotfile", "karabiner", "karabiner.json"), "Path to karabiner.json")
	outputPathPtr := flag.String("output", "", "Path for output karabiner.json (defaults to same as input)")

	flag.Parse()

	if *yamlPathPtr == "" {
		fmt.Println("Error: YAML rules path is required")
		fmt.Println("Usage: karabiner-rules --yaml <path-to-yaml-file> [--karabiner <path-to-karabiner.json>] [--output <output-path>]")
		flag.PrintDefaults()
		os.Exit(1)
	}

	// Set output path to input path if not specified
	if *outputPathPtr == "" {
		*outputPathPtr = *karabinerPathPtr
	}

	// Read the simplified YAML rules
	rulesConfig, err := readSimpleRules(*yamlPathPtr)
	if err != nil {
		fmt.Printf("Error reading YAML rules: %v\n", err)
		os.Exit(1)
	}

	// Read existing karabiner.json
	karabinerConfig, err := readKarabinerConfig(*karabinerPathPtr)
	if err != nil {
		fmt.Printf("Error reading karabiner.json: %v\n", err)
		os.Exit(1)
	}

	// Convert YAML rules to Karabiner rules
	var rules []Rule
	for _, simpleRule := range rulesConfig.Rules {
		rule := convertRule(simpleRule)
		rules = append(rules, rule)
	}

	// Replace only the rules in the existing config
	karabinerConfig.Profiles[0].ComplexModifications.Rules = rules

	// Write the updated config
	err = writeKarabinerConfig(karabinerConfig, *outputPathPtr)
	if err != nil {
		fmt.Printf("Error writing updated karabiner.json: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("Successfully updated rules in karabiner.json at %s\n", *outputPathPtr)
	fmt.Printf("Added %d rules from YAML config\n", len(rules))
}
