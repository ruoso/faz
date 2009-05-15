use Faz::Component;
role Faz::Container {
  has %!component;

  method register-component(Faz::Component $component) {
    my $com_name = $component.WHAT.perl;

    if %!component.exists($com_name) {
      die 'Component already registered';
    } else {
      %!component{$com_name} = $component;
    }
  }

  class ComponentProxy {
    has $!components;
    has $!type;

    my sub fullname ($name, $type) {
      my $app_name = $*app.WHAT.perl ~  '::';
      given $!type {
        when 'model' {
          $name = $app_name ~ 'Model::';
        }
        when 'view' {
          $name = $app_name ~ 'View::';
        }
      };
      return $name;
    }

    method postcircumfix:<{ }> ($name) {
      my $fullname = fullname($name, $!type);
      if %!components.exists($fullname) {
        return %!components{$fullname}.ACCEPT_CONTEXT;
      } else {
        die 'Component {$type} {$name} not found';
      }
    }

    method keys {
      my $basename = fullname('', $!type);
      return %!components.keys.grep: { .index($basename) };
    }

    method values {
      my $basename = fullname('', $!type);
      return map { %!components{$_} },
        grep { .index($basename) },
          %!components.keys;
    }

    method exists($name) {
      my $basename = fullname($name, $!type);
      return %!components.exists($basename);
    }
  }

  method model {
    return ComponentProxy.new(:components(%!component), :type('model'));
  }

  method view {
    return ComponentProxy.new(:components(%!component), :type('view'));
  }

  method component {
    return ComponentProxy.new(:components(%!component));
  }

}
