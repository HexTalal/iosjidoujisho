var A=function(e,r){return A=Object.setPrototypeOf||{__proto__:[]}instanceof Array&&function(t,n){t.__proto__=n}||function(t,n){for(var i in n)Object.prototype.hasOwnProperty.call(n,i)&&(t[i]=n[i])},A(e,r)};function m(e,r){if(typeof r!="function"&&r!==null)throw new TypeError("Class extends value "+String(r)+" is not a constructor or null");A(e,r);function t(){this.constructor=e}e.prototype=r===null?Object.create(r):(t.prototype=r.prototype,new t)}function st(e,r,t,n){function i(o){return o instanceof t?o:new t(function(u){u(o)})}return new(t||(t=Promise))(function(o,u){function s(f){try{a(n.next(f))}catch(d){u(d)}}function c(f){try{a(n.throw(f))}catch(d){u(d)}}function a(f){f.done?o(f.value):i(f.value).then(s,c)}a((n=n.apply(e,r||[])).next())})}function at(e,r){var t={label:0,sent:function(){if(o[0]&1)throw o[1];return o[1]},trys:[],ops:[]},n,i,o,u;return u={next:s(0),throw:s(1),return:s(2)},typeof Symbol=="function"&&(u[Symbol.iterator]=function(){return this}),u;function s(a){return function(f){return c([a,f])}}function c(a){if(n)throw new TypeError("Generator is already executing.");for(;t;)try{if(n=1,i&&(o=a[0]&2?i.return:a[0]?i.throw||((o=i.return)&&o.call(i),0):i.next)&&!(o=o.call(i,a[1])).done)return o;switch(i=0,o&&(a=[a[0]&2,o.value]),a[0]){case 0:case 1:o=a;break;case 4:return t.label++,{value:a[1],done:!1};case 5:t.label++,i=a[1],a=[0];continue;case 7:a=t.ops.pop(),t.trys.pop();continue;default:if(o=t.trys,!(o=o.length>0&&o[o.length-1])&&(a[0]===6||a[0]===2)){t=0;continue}if(a[0]===3&&(!o||a[1]>o[0]&&a[1]<o[3])){t.label=a[1];break}if(a[0]===6&&t.label<o[1]){t.label=o[1],o=a;break}if(o&&t.label<o[2]){t.label=o[2],t.ops.push(a);break}o[2]&&t.ops.pop(),t.trys.pop();continue}a=r.call(e,t)}catch(f){a=[6,f],i=0}finally{n=o=0}if(a[0]&5)throw a[1];return{value:a[0]?a[1]:void 0,done:!0}}}function b(e){var r=typeof Symbol=="function"&&Symbol.iterator,t=r&&e[r],n=0;if(t)return t.call(e);if(e&&typeof e.length=="number")return{next:function(){return e&&n>=e.length&&(e=void 0),{value:e&&e[n++],done:!e}}};throw new TypeError(r?"Object is not iterable.":"Symbol.iterator is not defined.")}function g(e,r){var t=typeof Symbol=="function"&&e[Symbol.iterator];if(!t)return e;var n=t.call(e),i,o=[],u;try{for(;(r===void 0||r-- >0)&&!(i=n.next()).done;)o.push(i.value)}catch(s){u={error:s}}finally{try{i&&!i.done&&(t=n.return)&&t.call(n)}finally{if(u)throw u.error}}return o}function E(e,r,t){if(t||arguments.length===2)for(var n=0,i=r.length,o;n<i;n++)(o||!(n in r))&&(o||(o=Array.prototype.slice.call(r,0,n)),o[n]=r[n]);return e.concat(o||Array.prototype.slice.call(r))}function C(e){return this instanceof C?(this.v=e,this):new C(e)}function ct(e,r,t){if(!Symbol.asyncIterator)throw new TypeError("Symbol.asyncIterator is not defined.");var n=t.apply(e,r||[]),i,o=[];return i={},u("next"),u("throw"),u("return"),i[Symbol.asyncIterator]=function(){return this},i;function u(l){n[l]&&(i[l]=function(p){return new Promise(function(y,h){o.push([l,p,y,h])>1||s(l,p)})})}function s(l,p){try{c(n[l](p))}catch(y){d(o[0][3],y)}}function c(l){l.value instanceof C?Promise.resolve(l.value.v).then(a,f):d(o[0][2],l)}function a(l){s("next",l)}function f(l){s("throw",l)}function d(l,p){l(p),o.shift(),o.length&&s(o[0][0],o[0][1])}}function lt(e){if(!Symbol.asyncIterator)throw new TypeError("Symbol.asyncIterator is not defined.");var r=e[Symbol.asyncIterator],t;return r?r.call(e):(e=typeof b=="function"?b(e):e[Symbol.iterator](),t={},n("next"),n("throw"),n("return"),t[Symbol.asyncIterator]=function(){return this},t);function n(o){t[o]=e[o]&&function(u){return new Promise(function(s,c){u=e[o](u),i(s,c,u.done,u.value)})}}function i(o,u,s,c){Promise.resolve(c).then(function(a){o({value:a,done:s})},u)}}function v(e){return typeof e=="function"}function H(e){var r=function(n){Error.call(n),n.stack=new Error().stack},t=e(r);return t.prototype=Object.create(Error.prototype),t.prototype.constructor=t,t}var P=H(function(e){return function(t){e(this),this.message=t?t.length+` errors occurred during unsubscription:
`+t.map(function(n,i){return i+1+") "+n.toString()}).join(`
  `):"",this.name="UnsubscriptionError",this.errors=t}});function U(e,r){if(e){var t=e.indexOf(r);0<=t&&e.splice(t,1)}}var O=function(){function e(r){this.initialTeardown=r,this.closed=!1,this._parentage=null,this._finalizers=null}return e.prototype.unsubscribe=function(){var r,t,n,i,o;if(!this.closed){this.closed=!0;var u=this._parentage;if(u)if(this._parentage=null,Array.isArray(u))try{for(var s=b(u),c=s.next();!c.done;c=s.next()){var a=c.value;a.remove(this)}}catch(h){r={error:h}}finally{try{c&&!c.done&&(t=s.return)&&t.call(s)}finally{if(r)throw r.error}}else u.remove(this);var f=this.initialTeardown;if(v(f))try{f()}catch(h){o=h instanceof P?h.errors:[h]}var d=this._finalizers;if(d){this._finalizers=null;try{for(var l=b(d),p=l.next();!p.done;p=l.next()){var y=p.value;try{B(y)}catch(h){o=o!=null?o:[],h instanceof P?o=E(E([],g(o)),g(h.errors)):o.push(h)}}}catch(h){n={error:h}}finally{try{p&&!p.done&&(i=l.return)&&i.call(l)}finally{if(n)throw n.error}}}if(o)throw new P(o)}},e.prototype.add=function(r){var t;if(r&&r!==this)if(this.closed)B(r);else{if(r instanceof e){if(r.closed||r._hasParent(this))return;r._addParent(this)}(this._finalizers=(t=this._finalizers)!==null&&t!==void 0?t:[]).push(r)}},e.prototype._hasParent=function(r){var t=this._parentage;return t===r||Array.isArray(t)&&t.includes(r)},e.prototype._addParent=function(r){var t=this._parentage;this._parentage=Array.isArray(t)?(t.push(r),t):t?[t,r]:r},e.prototype._removeParent=function(r){var t=this._parentage;t===r?this._parentage=null:Array.isArray(t)&&U(t,r)},e.prototype.remove=function(r){var t=this._finalizers;t&&U(t,r),r instanceof e&&r._removeParent(this)},e.EMPTY=function(){var r=new e;return r.closed=!0,r}(),e}(),R=O.EMPTY;function q(e){return e instanceof O||e&&"closed"in e&&v(e.remove)&&v(e.add)&&v(e.unsubscribe)}function B(e){v(e)?e():e.unsubscribe()}var T={onUnhandledError:null,onStoppedNotification:null,Promise:void 0,useDeprecatedSynchronousErrorHandling:!1,useDeprecatedNextContext:!1},x={setTimeout:function(e,r){for(var t=[],n=2;n<arguments.length;n++)t[n-2]=arguments[n];var i=x.delegate;return i!=null&&i.setTimeout?i.setTimeout.apply(i,E([e,r],g(t))):setTimeout.apply(void 0,E([e,r],g(t)))},clearTimeout:function(e){var r=x.delegate;return((r==null?void 0:r.clearTimeout)||clearTimeout)(e)},delegate:void 0};function J(e){x.setTimeout(function(){throw e})}function M(){}var K=function(){return F("C",void 0,void 0)}();function Q(e){return F("E",void 0,e)}function X(e){return F("N",e,void 0)}function F(e,r,t){return{kind:e,value:r,error:t}}var S=null;function _(e){if(T.useDeprecatedSynchronousErrorHandling){var r=!S;if(r&&(S={errorThrown:!1,error:null}),e(),r){var t=S,n=t.errorThrown,i=t.error;if(S=null,n)throw i}}else e()}var G=function(e){m(r,e);function r(t){var n=e.call(this)||this;return n.isStopped=!1,t?(n.destination=t,q(t)&&t.add(n)):n.destination=N,n}return r.create=function(t,n,i){return new k(t,n,i)},r.prototype.next=function(t){this.isStopped?I(X(t),this):this._next(t)},r.prototype.error=function(t){this.isStopped?I(Q(t),this):(this.isStopped=!0,this._error(t))},r.prototype.complete=function(){this.isStopped?I(K,this):(this.isStopped=!0,this._complete())},r.prototype.unsubscribe=function(){this.closed||(this.isStopped=!0,e.prototype.unsubscribe.call(this),this.destination=null)},r.prototype._next=function(t){this.destination.next(t)},r.prototype._error=function(t){try{this.destination.error(t)}finally{this.unsubscribe()}},r.prototype._complete=function(){try{this.destination.complete()}finally{this.unsubscribe()}},r}(O),Z=Function.prototype.bind;function j(e,r){return Z.call(e,r)}var $=function(){function e(r){this.partialObserver=r}return e.prototype.next=function(r){var t=this.partialObserver;if(t.next)try{t.next(r)}catch(n){w(n)}},e.prototype.error=function(r){var t=this.partialObserver;if(t.error)try{t.error(r)}catch(n){w(n)}else w(r)},e.prototype.complete=function(){var r=this.partialObserver;if(r.complete)try{r.complete()}catch(t){w(t)}},e}(),k=function(e){m(r,e);function r(t,n,i){var o=e.call(this)||this,u;if(v(t)||!t)u={next:t!=null?t:void 0,error:n!=null?n:void 0,complete:i!=null?i:void 0};else{var s;o&&T.useDeprecatedNextContext?(s=Object.create(t),s.unsubscribe=function(){return o.unsubscribe()},u={next:t.next&&j(t.next,s),error:t.error&&j(t.error,s),complete:t.complete&&j(t.complete,s)}):u=t}return o.destination=new $(u),o}return r}(G);function w(e){J(e)}function z(e){throw e}function I(e,r){var t=T.onStoppedNotification;t&&x.setTimeout(function(){return t(e,r)})}var N={closed:!0,next:M,error:z,complete:M},tt=function(){return typeof Symbol=="function"&&Symbol.observable||"@@observable"}();function rt(e){return e}function ft(){for(var e=[],r=0;r<arguments.length;r++)e[r]=arguments[r];return L(e)}function L(e){return e.length===0?rt:e.length===1?e[0]:function(t){return e.reduce(function(n,i){return i(n)},t)}}var D=function(){function e(r){r&&(this._subscribe=r)}return e.prototype.lift=function(r){var t=new e;return t.source=this,t.operator=r,t},e.prototype.subscribe=function(r,t,n){var i=this,o=nt(r)?r:new k(r,t,n);return _(function(){var u=i,s=u.operator,c=u.source;o.add(s?s.call(o,c):c?i._subscribe(o):i._trySubscribe(o))}),o},e.prototype._trySubscribe=function(r){try{return this._subscribe(r)}catch(t){r.error(t)}},e.prototype.forEach=function(r,t){var n=this;return t=V(t),new t(function(i,o){var u=new k({next:function(s){try{r(s)}catch(c){o(c),u.unsubscribe()}},error:o,complete:i});n.subscribe(u)})},e.prototype._subscribe=function(r){var t;return(t=this.source)===null||t===void 0?void 0:t.subscribe(r)},e.prototype[tt]=function(){return this},e.prototype.pipe=function(){for(var r=[],t=0;t<arguments.length;t++)r[t]=arguments[t];return L(r)(this)},e.prototype.toPromise=function(r){var t=this;return r=V(r),new r(function(n,i){var o;t.subscribe(function(u){return o=u},function(u){return i(u)},function(){return n(o)})})},e.create=function(r){return new e(r)},e}();function V(e){var r;return(r=e!=null?e:T.Promise)!==null&&r!==void 0?r:Promise}function et(e){return e&&v(e.next)&&v(e.error)&&v(e.complete)}function nt(e){return e&&e instanceof G||et(e)&&q(e)}var ot=H(function(e){return function(){e(this),this.name="ObjectUnsubscribedError",this.message="object unsubscribed"}}),W=function(e){m(r,e);function r(){var t=e.call(this)||this;return t.closed=!1,t.currentObservers=null,t.observers=[],t.isStopped=!1,t.hasError=!1,t.thrownError=null,t}return r.prototype.lift=function(t){var n=new Y(this,this);return n.operator=t,n},r.prototype._throwIfClosed=function(){if(this.closed)throw new ot},r.prototype.next=function(t){var n=this;_(function(){var i,o;if(n._throwIfClosed(),!n.isStopped){n.currentObservers||(n.currentObservers=Array.from(n.observers));try{for(var u=b(n.currentObservers),s=u.next();!s.done;s=u.next()){var c=s.value;c.next(t)}}catch(a){i={error:a}}finally{try{s&&!s.done&&(o=u.return)&&o.call(u)}finally{if(i)throw i.error}}}})},r.prototype.error=function(t){var n=this;_(function(){if(n._throwIfClosed(),!n.isStopped){n.hasError=n.isStopped=!0,n.thrownError=t;for(var i=n.observers;i.length;)i.shift().error(t)}})},r.prototype.complete=function(){var t=this;_(function(){if(t._throwIfClosed(),!t.isStopped){t.isStopped=!0;for(var n=t.observers;n.length;)n.shift().complete()}})},r.prototype.unsubscribe=function(){this.isStopped=this.closed=!0,this.observers=this.currentObservers=null},Object.defineProperty(r.prototype,"observed",{get:function(){var t;return((t=this.observers)===null||t===void 0?void 0:t.length)>0},enumerable:!1,configurable:!0}),r.prototype._trySubscribe=function(t){return this._throwIfClosed(),e.prototype._trySubscribe.call(this,t)},r.prototype._subscribe=function(t){return this._throwIfClosed(),this._checkFinalizedStatuses(t),this._innerSubscribe(t)},r.prototype._innerSubscribe=function(t){var n=this,i=this,o=i.hasError,u=i.isStopped,s=i.observers;return o||u?R:(this.currentObservers=null,s.push(t),new O(function(){n.currentObservers=null,U(s,t)}))},r.prototype._checkFinalizedStatuses=function(t){var n=this,i=n.hasError,o=n.thrownError,u=n.isStopped;i?t.error(o):u&&t.complete()},r.prototype.asObservable=function(){var t=new D;return t.source=this,t},r.create=function(t,n){return new Y(t,n)},r}(D),Y=function(e){m(r,e);function r(t,n){var i=e.call(this)||this;return i.destination=t,i.source=n,i}return r.prototype.next=function(t){var n,i;(i=(n=this.destination)===null||n===void 0?void 0:n.next)===null||i===void 0||i.call(n,t)},r.prototype.error=function(t){var n,i;(i=(n=this.destination)===null||n===void 0?void 0:n.error)===null||i===void 0||i.call(n,t)},r.prototype.complete=function(){var t,n;(n=(t=this.destination)===null||t===void 0?void 0:t.complete)===null||n===void 0||n.call(t)},r.prototype._subscribe=function(t){var n,i;return(i=(n=this.source)===null||n===void 0?void 0:n.subscribe(t))!==null&&i!==void 0?i:R},r}(W),it=function(e){m(r,e);function r(t){var n=e.call(this)||this;return n._value=t,n}return Object.defineProperty(r.prototype,"value",{get:function(){return this.getValue()},enumerable:!1,configurable:!0}),r.prototype._subscribe=function(t){var n=e.prototype._subscribe.call(this,t);return!n.closed&&t.next(this._value),n},r.prototype.getValue=function(){var t=this,n=t.hasError,i=t.thrownError,o=t._value;if(n)throw i;return this._throwIfClosed(),o},r.prototype.next=function(t){e.prototype.next.call(this,this._value=t)},r}(W);/**
 * @license BSD-3-Clause
 * Copyright (c) 2022, ッツ Reader Authors
 * All rights reserved.
 */function ut(e){return e.set=e.next,e}/**
 * @license BSD-3-Clause
 * Copyright (c) 2022, ッツ Reader Authors
 * All rights reserved.
 */function ht(e){return ut(new it(e))}export{it as B,D as O,O as S,E as _,g as a,m as b,U as c,rt as d,W as e,G as f,ct as g,at as h,v as i,C as j,st as k,b as l,lt as m,M as n,tt as o,k as p,ft as q,J as r,ht as w};
