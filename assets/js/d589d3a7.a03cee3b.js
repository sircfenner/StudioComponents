"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[7162],{3905:(e,t,n)=>{n.d(t,{Zo:()=>c,kt:()=>f});var r=n(67294);function o(e,t,n){return t in e?Object.defineProperty(e,t,{value:n,enumerable:!0,configurable:!0,writable:!0}):e[t]=n,e}function a(e,t){var n=Object.keys(e);if(Object.getOwnPropertySymbols){var r=Object.getOwnPropertySymbols(e);t&&(r=r.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),n.push.apply(n,r)}return n}function i(e){for(var t=1;t<arguments.length;t++){var n=null!=arguments[t]?arguments[t]:{};t%2?a(Object(n),!0).forEach((function(t){o(e,t,n[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(n)):a(Object(n)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(n,t))}))}return e}function l(e,t){if(null==e)return{};var n,r,o=function(e,t){if(null==e)return{};var n,r,o={},a=Object.keys(e);for(r=0;r<a.length;r++)n=a[r],t.indexOf(n)>=0||(o[n]=e[n]);return o}(e,t);if(Object.getOwnPropertySymbols){var a=Object.getOwnPropertySymbols(e);for(r=0;r<a.length;r++)n=a[r],t.indexOf(n)>=0||Object.prototype.propertyIsEnumerable.call(e,n)&&(o[n]=e[n])}return o}var s=r.createContext({}),p=function(e){var t=r.useContext(s),n=t;return e&&(n="function"==typeof e?e(t):i(i({},t),e)),n},c=function(e){var t=p(e.components);return r.createElement(s.Provider,{value:t},e.children)},u="mdxType",d={inlineCode:"code",wrapper:function(e){var t=e.children;return r.createElement(r.Fragment,{},t)}},m=r.forwardRef((function(e,t){var n=e.components,o=e.mdxType,a=e.originalType,s=e.parentName,c=l(e,["components","mdxType","originalType","parentName"]),u=p(n),m=o,f=u["".concat(s,".").concat(m)]||u[m]||d[m]||a;return n?r.createElement(f,i(i({ref:t},c),{},{components:n})):r.createElement(f,i({ref:t},c))}));function f(e,t){var n=arguments,o=t&&t.mdxType;if("string"==typeof e||o){var a=n.length,i=new Array(a);i[0]=m;var l={};for(var s in t)hasOwnProperty.call(t,s)&&(l[s]=t[s]);l.originalType=e,l[u]="string"==typeof e?e:o,i[1]=l;for(var p=2;p<a;p++)i[p]=n[p];return r.createElement.apply(null,i)}return r.createElement.apply(null,n)}m.displayName="MDXCreateElement"},99390:(e,t,n)=>{n.r(t),n.d(t,{assets:()=>s,contentTitle:()=>i,default:()=>d,frontMatter:()=>a,metadata:()=>l,toc:()=>p});var r=n(87462),o=(n(67294),n(3905));const a={sidebar_position:2},i="Getting Started",l={unversionedId:"getting-started",id:"getting-started",title:"Getting Started",description:"This project is built for react-lua, which can be installed either via NPM/yarn, wally, or a release. See the repository for more information.",source:"@site/docs/getting-started.md",sourceDirName:".",slug:"/getting-started",permalink:"/StudioComponents/docs/getting-started",draft:!1,editUrl:"https://github.com/sircfenner/StudioComponents/edit/main/docs/getting-started.md",tags:[],version:"current",sidebarPosition:2,frontMatter:{sidebar_position:2},sidebar:"defaultSidebar",previous:{title:"About",permalink:"/StudioComponents/docs/intro"}},s={},p=[{value:"Installation",id:"installation",level:2},{value:"Wally",id:"wally",level:3},{value:"NPM &amp; yarn",id:"npm--yarn",level:3}],c={toc:p},u="wrapper";function d(e){let{components:t,...n}=e;return(0,o.kt)(u,(0,r.Z)({},c,n,{components:t,mdxType:"MDXLayout"}),(0,o.kt)("h1",{id:"getting-started"},"Getting Started"),(0,o.kt)("p",null,"This project is built for react-lua, which can be installed either via NPM/yarn, wally, or a release. See the ",(0,o.kt)("a",{parentName:"p",href:"https://github.com/jsdotlua/react-lua"},"repository")," for more information."),(0,o.kt)("p",null,"StudioComponents exposes a table of components, hooks, and a reference to the Constants file. Minimal example of using a component from StudioComponents:"),(0,o.kt)("pre",null,(0,o.kt)("code",{parentName:"pre",className:"language-lua"},'local React = require(Packages.React)\nlocal StudioComponents = require(Packages.StudioComponents)\n\nlocal function MyComponent()\n    return React.createElement(StudioComponents.Label, {\n        Text = "Hello, from StudioComponents!"\n    })\nend\n')),(0,o.kt)("h2",{id:"installation"},"Installation"),(0,o.kt)("h3",{id:"wally"},"Wally"),(0,o.kt)("p",null,"Add ",(0,o.kt)("inlineCode",{parentName:"p"},"studiocomponents")," to your ",(0,o.kt)("inlineCode",{parentName:"p"},"wally.toml"),":"),(0,o.kt)("pre",null,(0,o.kt)("code",{parentName:"pre",className:"language-toml"},'studiocomponents = "sircfenner/studiocomponents@1.0.0"\n')),(0,o.kt)("h3",{id:"npm--yarn"},"NPM & yarn"),(0,o.kt)("p",null,"Add ",(0,o.kt)("inlineCode",{parentName:"p"},"studiocomponents")," to your dependencies:"),(0,o.kt)("pre",null,(0,o.kt)("code",{parentName:"pre",className:"language-bash"},"npm install studiocomponents\n")),(0,o.kt)("pre",null,(0,o.kt)("code",{parentName:"pre",className:"language-bash"},"yarn add studiocomponents\n")),(0,o.kt)("p",null,"Run ",(0,o.kt)("inlineCode",{parentName:"p"},"npmluau"),"."))}d.isMDXComponent=!0}}]);